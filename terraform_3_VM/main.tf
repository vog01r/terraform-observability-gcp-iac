# VPC Network
resource "google_compute_network" "observability_vpc" {
  name                    = "observability-vpc"
  auto_create_subnetworks = false
  description             = "VPC for observability TP"
}

# Subnet
resource "google_compute_subnetwork" "observability_subnet" {
  name          = "observability-subnet"
  ip_cidr_range = var.network_cidr
  region        = var.region
  network       = google_compute_network.observability_vpc.id
}

# Firewall Rules - Allow everything for simplicity
resource "google_compute_firewall" "allow_all" {
  name    = "allow-all-traffic"
  network = google_compute_network.observability_vpc.name

  allow {
    protocol = "tcp"
    ports    = []
  }

  allow {
    protocol = "udp"
    ports    = []
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-all"]
}

# SSH Key
data "local_file" "ssh_public_key" {
  filename = pathexpand(var.ssh_public_key_path)
}

# App VM
resource "google_compute_instance" "vm_app" {
  name         = "vm-app"
  machine_type = var.app_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "${var.image_project}/${var.image_family}"
      size  = var.boot_disk_size
    }
  }

  network_interface {
    network    = google_compute_network.observability_vpc.id
    subnetwork = google_compute_subnetwork.observability_subnet.id
    
    access_config {
      # Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${data.local_file.ssh_public_key.content}"
    startup-script = <<-EOF
      #!/bin/bash
      # Disable local firewall
      ufw --force disable
      iptables -F
      iptables -X
      iptables -t nat -F
      iptables -t nat -X
      iptables -t mangle -F
      iptables -t mangle -X
      iptables -P INPUT ACCEPT
      iptables -P FORWARD ACCEPT
      iptables -P OUTPUT ACCEPT
      
      # Update system
      apt-get update
      apt-get install -y python3 python3-pip curl jq
      
      # Install Flask app
      mkdir -p /opt/app
      cat > /opt/app/app.py << 'EOL'
from flask import Flask, jsonify
import datetime
import random
from prometheus_client import generate_latest, Counter, Gauge, Histogram

app = Flask(__name__)

# Prometheus metrics
REQUEST_COUNT = Counter('flask_app_requests_total', 'Total number of requests to Flask app')
HEALTH_CHECK_COUNT = Counter('flask_app_health_checks_total', 'Total number of health checks')
ERROR_COUNT = Counter('flask_app_errors_total', 'Total number of errors')
UPTIME_GAUGE = Gauge('flask_app_uptime_seconds', 'Uptime of the Flask app in seconds')
REQUEST_LATENCY_HISTOGRAM = Histogram('flask_app_request_latency_seconds', 'Request latency in seconds')

start_time = datetime.datetime.now()
total_requests = 0
error_requests = 0

@app.route('/')
def home():
    REQUEST_COUNT.inc()
    with REQUEST_LATENCY_HISTOGRAM.time():
        global total_requests
        total_requests += 1
        uptime = (datetime.datetime.now() - start_time).total_seconds()
        UPTIME_GAUGE.set(uptime)
        return jsonify({
            "message": "Observability TP - Flask App",
            "status": "running",
            "timestamp": datetime.datetime.now().isoformat()
        })

@app.route('/health')
def health():
    REQUEST_COUNT.inc()
    HEALTH_CHECK_COUNT.inc()
    with REQUEST_LATENCY_HISTOGRAM.time():
        global total_requests, error_requests
        total_requests += 1
        if random.random() < 0.1:  # Simulate 10% error rate
            error_requests += 1
            ERROR_COUNT.inc()
            return jsonify({
                "message": "Health check failed",
                "status": "unhealthy",
                "timestamp": datetime.datetime.now().isoformat()
            }), 500
        return jsonify({
            "message": "Health check passed",
            "status": "healthy",
            "timestamp": datetime.datetime.now().isoformat()
        })

@app.route('/stats')
def stats():
    REQUEST_COUNT.inc()
    with REQUEST_LATENCY_HISTOGRAM.time():
        global total_requests, error_requests
        uptime = (datetime.datetime.now() - start_time).total_seconds()
        UPTIME_GAUGE.set(uptime)
        error_rate = (error_requests / total_requests) * 100 if total_requests > 0 else 0
        return jsonify({
            "total_requests": total_requests,
            "error_requests": error_requests,
            "error_rate": round(error_rate, 2),
            "uptime_seconds": round(uptime),
            "timestamp": datetime.datetime.now().isoformat()
        })

@app.route('/metrics')
def metrics():
    return generate_latest().decode('utf-8')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
EOL
      
      # Install Flask and Prometheus client
      pip3 install flask prometheus_client
      
      # Create systemd service
      cat > /etc/systemd/system/flask-app.service << 'EOL'
[Unit]
Description=Flask App for Observability TP
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=/opt/app
ExecStart=/usr/bin/python3 /opt/app/app.py
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=flask-app

[Install]
WantedBy=multi-user.target
EOL
      
      # Start Flask service
      systemctl daemon-reload
      systemctl enable flask-app
      systemctl start flask-app
    EOF
  }

  tags = ["allow-all"]
  
  labels = merge(var.labels, {
    role = "app"
  })

  allow_stopping_for_update = true
}

# Prometheus VM
resource "google_compute_instance" "vm_zabbix" {
  name         = "vm-zabbix"
  machine_type = var.zabbix_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "${var.image_project}/${var.image_family}"
      size  = var.boot_disk_size
    }
  }

  network_interface {
    network    = google_compute_network.observability_vpc.id
    subnetwork = google_compute_subnetwork.observability_subnet.id
    
    access_config {
      # Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${data.local_file.ssh_public_key.content}"
    startup-script = <<-EOF
      #!/bin/bash
      # Disable local firewall
      ufw --force disable
      iptables -F
      iptables -X
      iptables -t nat -F
      iptables -t nat -X
      iptables -t mangle -F
      iptables -t mangle -X
      iptables -P INPUT ACCEPT
      iptables -P FORWARD ACCEPT
      iptables -P OUTPUT ACCEPT
      
      # Update system
      apt-get update
      apt-get install -y curl wget
      
      # Download and install Prometheus
      cd /opt
      wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
      tar xzf prometheus-2.45.0.linux-amd64.tar.gz
      mv prometheus-2.45.0.linux-amd64 prometheus
      
      # Create Prometheus config
      cat > /etc/prometheus/prometheus.yml << 'EOL'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'flask-app'
    static_configs:
      - targets: ['10.42.0.3:5000']
EOL
      
      # Create systemd service
      cat > /etc/systemd/system/prometheus.service << 'EOL'
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/opt/prometheus/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/opt/prometheus/consoles \
    --web.console.libraries=/opt/prometheus/console_libraries \
    --web.listen-address=0.0.0.0:9090 \
    --web.enable-lifecycle
Restart=always

[Install]
WantedBy=multi-user.target
EOL
      
      # Start Prometheus service
      systemctl daemon-reload
      systemctl enable prometheus
      systemctl start prometheus
    EOF
  }

  tags = ["allow-all"]
  
  labels = merge(var.labels, {
    role = "prometheus"
  })

  allow_stopping_for_update = true
}

# Grafana VM
resource "google_compute_instance" "vm_grafana" {
  name         = "vm-grafana"
  machine_type = var.grafana_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "${var.image_project}/${var.image_family}"
      size  = var.boot_disk_size
    }
  }

  network_interface {
    network    = google_compute_network.observability_vpc.id
    subnetwork = google_compute_subnetwork.observability_subnet.id
    
    access_config {
      # Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${data.local_file.ssh_public_key.content}"
    startup-script = <<-EOF
      #!/bin/bash
      # Disable local firewall
      ufw --force disable
      iptables -F
      iptables -X
      iptables -t nat -F
      iptables -t nat -X
      iptables -t mangle -F
      iptables -t mangle -X
      iptables -P INPUT ACCEPT
      iptables -P FORWARD ACCEPT
      iptables -P OUTPUT ACCEPT
      
      # Update system
      apt-get update
      apt-get install -y curl wget gnupg2 software-properties-common
      
      # Install Grafana
      wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
      echo "deb https://packages.grafana.com/oss/deb stable main" | tee -a /etc/apt/sources.list.d/grafana.list
      apt-get update
      apt-get install -y grafana
      
      # Configure Grafana
      cat > /etc/grafana/provisioning/datasources/prometheus.yml << 'EOL'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://10.42.0.4:9090
    isDefault: true
EOL
      
      # Start Grafana service
      systemctl daemon-reload
      systemctl enable grafana-server
      systemctl start grafana-server
    EOF
  }

  tags = ["allow-all"]
  
  labels = merge(var.labels, {
    role = "grafana"
  })

  allow_stopping_for_update = true
}

# Generate Ansible inventory
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.ini.tmpl", {
    app_ip   = google_compute_instance.vm_app.network_interface[0].network_ip
    zbx_ip   = google_compute_instance.vm_zabbix.network_interface[0].network_ip
    graf_ip  = google_compute_instance.vm_grafana.network_interface[0].network_ip
    ssh_user = var.ssh_user
  })
  filename = "${path.module}/../ansible/inventory/inventory.ini"
}