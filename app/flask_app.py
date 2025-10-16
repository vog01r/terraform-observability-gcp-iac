#!/usr/bin/env python3
import os
import time
import random
import json
from datetime import datetime
from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

# Prometheus metrics
REQUEST_COUNT = Counter('flask_requests_total', 'Total requests', ['method', 'endpoint', 'status'])
REQUEST_DURATION = Histogram('flask_request_duration_seconds', 'Request duration')
ERROR_COUNT = Counter('flask_errors_total', 'Total errors', ['error_type'])
ERROR_RATE = Gauge('flask_error_rate', 'Current error rate percentage')
UPTIME_GAUGE = Gauge('flask_uptime_seconds', 'Application uptime in seconds')

# Global variables for stats
start_time = time.time()
error_count = 0
request_count = 0

@app.route('/')
def home():
    global request_count
    request_count += 1
    
    # Simulate 5% error rate on home page
    if random.random() < 0.05:
        ERROR_COUNT.labels(error_type='home_error').inc()
        REQUEST_COUNT.labels(method='GET', endpoint='/', status='500').inc()
        return jsonify({
            'message': 'Internal Server Error',
            'status': 'error',
            'timestamp': datetime.now().isoformat()
        }), 500
    
    REQUEST_COUNT.labels(method='GET', endpoint='/', status='200').inc()
    return jsonify({
        'message': 'Observability TP - Flask App with Prometheus',
        'status': 'running',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/health')
def health():
    global request_count, error_count
    request_count += 1
    
    # Simulate 20% error rate for health checks
    if random.random() < 0.2:
        error_count += 1
        ERROR_COUNT.labels(error_type='health_check_failed').inc()
        REQUEST_COUNT.labels(method='GET', endpoint='/health', status='500').inc()
        return jsonify({
            'status': 'error',
            'message': 'Health check failed',
            'timestamp': datetime.now().isoformat()
        }), 500
    
    REQUEST_COUNT.labels(method='GET', endpoint='/health', status='200').inc()
    return jsonify({
        'status': 'healthy',
        'message': 'Health check passed',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/error')
def generate_error():
    """Endpoint to manually generate errors"""
    global request_count, error_count
    request_count += 1
    
    error_types = ['validation_error', 'database_error', 'timeout_error', 'permission_error']
    error_type = random.choice(error_types)
    
    error_count += 1
    ERROR_COUNT.labels(error_type=error_type).inc()
    REQUEST_COUNT.labels(method='GET', endpoint='/error', status='500').inc()
    
    return jsonify({
        'status': 'error',
        'error_type': error_type,
        'message': f'Simulated {error_type}',
        'timestamp': datetime.now().isoformat()
    }), 500

@app.route('/slow')
def slow_endpoint():
    """Endpoint that sometimes times out"""
    global request_count
    request_count += 1
    
    # Simulate slow response (30% chance of timeout)
    if random.random() < 0.3:
        time.sleep(2)  # Simulate timeout
        ERROR_COUNT.labels(error_type='timeout').inc()
        REQUEST_COUNT.labels(method='GET', endpoint='/slow', status='408').inc()
        return jsonify({
            'status': 'error',
            'message': 'Request timeout',
            'timestamp': datetime.now().isoformat()
        }), 408
    
    REQUEST_COUNT.labels(method='GET', endpoint='/slow', status='200').inc()
    return jsonify({
        'status': 'success',
        'message': 'Slow request completed',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/stats')
def stats():
    global request_count, error_count, start_time
    request_count += 1
    
    uptime = time.time() - start_time
    error_rate = (error_count / request_count) * 100 if request_count > 0 else 0
    
    # Update Prometheus gauges
    UPTIME_GAUGE.set(uptime)
    ERROR_RATE.set(error_rate)
    
    REQUEST_COUNT.labels(method='GET', endpoint='/stats', status='200').inc()
    return jsonify({
        'uptime_seconds': int(uptime),
        'total_requests': request_count,
        'error_count': error_count,
        'error_rate': round(error_rate, 2),
        'timestamp': datetime.now().isoformat()
    })

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
