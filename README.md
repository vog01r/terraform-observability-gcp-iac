# Observabilité GCP · Infrastructure as Code

> Plateforme d’observabilité clé en main : provision GCP automatisé par Terraform, configuration applicative via Ansible, dashboards prêts à l’emploi.

## Pourquoi ce dépôt ?

- Illustrer un **cas d’usage complet** : application, collecte de métriques, visualisation.
- Montrer une **hygiène IaC** : code versionné, scripts ciblés, documentation claire.
- Servir de **portfolio technique** pour GCP, Terraform, Ansible et observabilité.

## Architecture

| Couche | Technologies | Rôle |
| --- | --- | --- |
| Infrastructure | Terraform + GCP | VPC privé, 3 VM (App Flask, Zabbix, Grafana), firewall |
| Provisioning | Ansible | Installation OS, services, agents, dashboards |
| Application | Flask + Prometheus client | API + métriques `/metrics` exposées |
| Visualisation | Grafana + plugin Zabbix | Dashboard prêt à l’emploi |
| Documentation | Markdown (`docs/`) | Guides, TP, support de cours |

## Parcours en 5 minutes

```bash
git clone git@github.com:vog01r/terraform-observability-gcp-iac.git
cd terraform-observability-gcp-iac
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Éditer terraform.tfvars (project_id, ssh_user, etc.)
export GOOGLE_APPLICATION_CREDENTIALS="/chemin/vers/cle.json"
make all
```

Résultat :

- `http://APP_IP:5000` (Flask + métriques)
- `http://ZABBIX_IP/zabbix` (Admin / zabbix)
- `http://GRAFANA_IP:3000` (admin / admin + dashboard fourni)

## Dossier par dossier

- `terraform/` : configuration principale (VPC, instances, outputs, inventaire Ansible)
- `ansible/` : playbooks et rôles (`app`, `zabbix_server`, `grafana`, `common`)
- `scripts/` : utilitaires `check-ssh.sh`, `export-tf-outputs.sh`
- `docs/` : documentation structurée (`INSTALLATION.md`, `TP.md`, `Cours_Observabilite.md`…)
- `archive/` : anciens TP et expérimentations sont conservés mais isolés

## Bonnes pratiques intégrées

- Secrets exclus du repo, inventaire généré automatiquement
- Makefile pour orchestrer Terraform + Ansible (`make all`, `make destroy`, `make outputs`)
- Règles firewall minimales (à durcir selon le contexte prod)
- Scripts d’observation pour vérifier la connectivité et exporter les outputs

## Pistes d’amélioration

- Pipeline CI/CD pour valider plan Terraform, lint Ansible, tests d’intégration
- Modules Terraform réutilisables (VPC, VM observabilité)
- Intégration d’un bastion SSH, secrets manager, HTTPS automatique
- Export Prometheus vers Grafana Cloud ou autres backends

## Documentation

- `docs/INSTALLATION.md` : guide pas à pas
- `docs/TP.md` : scénario pédagogique
- `docs/Cours_Observabilite.md` : support complet (cours magistral)
- `docs/README.legacy.md` : ancienne version conservée pour référence historique

## Licence & Contact

- Licence : MIT. Merci de détruire l’infrastructure après usage (`make destroy`).
- Contact : `vog01r` / kevin.hamon@intra-tech.fr

---

> Ce dépôt est prêt pour mettre en avant une stack d’observabilité complète : capture de dashboard dans `docs/assets/`, README orienté storytelling, sections claires pour expliquer la stack.

