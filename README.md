## Monitoring

# 🚀 End-to-End MERN Application Deployment and Monitoring on AWS

This project automates the deployment, configuration, and monitoring of a production-grade MERN stack application using:

- 🛠️ **Terraform** for infrastructure provisioning (AWS)
- ⚙️ **Ansible** for server configuration and app deployment
- 📈 **Prometheus** for monitoring metrics
- 📊 **Grafana** for observability dashboards

---

## 🔗 Project App Source
Using the open-source MERN travel memory app:
> https://github.com/UnpredictablePrashant/TravelMemory

---

## 📁 Project Structure

```
MERN_Infra_Deployment/
├── terraform/              # Terraform scripts
├── ansible/                # Ansible playbooks & inventory
├── monitoring/
│   ├── prometheus/         # Prometheus configs
│   └── grafana/            # Grafana datasource configs

```

---

## ✅ Prerequisites

- AWS account with credentials configured (`~/.aws/credentials`)
- SSH key pair created in AWS (named `mern-key`)
- Terraform installed
- Ansible installed
- EC2 default VPC and subnet (auto-created in AWS)

---

## 🌐 1. Infrastructure Provisioning (Terraform)

Navigate to the terraform directory:
```bash
cd terraform
terraform init
terraform apply
```

✅ This will:
- Launch **2 EC2 instances**:
  - 1 for the **MERN app**
  - 1 for **MongoDB**
- Configure **security groups**, **networking**, and **public IPs**

> ⚠️ Make note of the Terraform output for:
> - `app_server_public_ip`
> - `db_server_public_ip`

---

## ⚙️ 2. Server Configuration & App Deployment (Ansible)

### 🔧 Setup

Replace `APP_SERVER_PUBLIC_IP` and `DB_SERVER_PUBLIC_IP` in:

```ini
ansible/inventory.ini
```

Then run the playbooks:

### 🖥️ App Server:
```bash
ansible-playbook -i inventory.ini app_setup.yml
```

This:
- Installs Node.js & Git
- Clones the app repo
- Installs backend/frontend dependencies
- Configures `.env` and launches backend/frontend

### 🗄️ Database Server:
```bash
ansible-playbook -i inventory.ini db_setup.yml
```

This:
- Installs MongoDB
- Enables remote access
- Starts MongoDB service

---

## 📊 3. Monitoring Setup (Prometheus + Grafana)

### 🚀 Prometheus (on App Server)

Deploy `prometheus.yml` and run:
```bash
sudo cp prometheus.yml /etc/prometheus/prometheus.yml
sudo cp prometheus.service /etc/systemd/system/prometheus.service
sudo systemctl daemon-reexec
sudo systemctl enable prometheus
sudo systemctl start prometheus
```

Prometheus will start on: `http://<APP_SERVER_PUBLIC_IP>:9090`

> Scrapes:
> - Node.js backend (custom metrics via prom-client)
> - MongoDB Exporter (`9216`)

---

### 📊 Grafana (on App Server)

Install Grafana and load the datasource:
```bash
sudo cp datasource.yml /etc/grafana/provisioning/datasources/
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
```

Grafana UI: `http://<APP_SERVER_PUBLIC_IP>:3000`  
Default login: `admin / admin`

---

## 📦 Sample `.env` (Backend)

Place inside `backend/.env`:
```
PORT=5000
MONGO_URI=mongodb://<DB_SERVER_PRIVATE_IP>:27017/travelmemories
```

---

## 📈 Observability & Dashboards

### Prometheus Metrics

- Node.js custom metrics: `/metrics`
- MongoDB Exporter: `:9216/metrics`

### Grafana Dashboards (create manually or upload JSON):
- API Request Rate / Latency
- Error Rate
- MongoDB Query Ops

---

## 🚨 Alerting

Set Grafana alerts on:
- 🔥 High API error rates
- 🐢 Slow responses
- 📉 MongoDB connection failures

---

## 📁 Final Deliverables

```
terraform/              # All Terraform infra code
ansible/                # Playbooks + inventory
monitoring/             # Prometheus + Grafana config

```

---

## 🏁 Final Notes

- Use `nohup` or PM2 to keep backend/frontend running
- All secrets should be redacted in public repos
- Use `systemctl` to ensure Prometheus/Grafana auto-start
