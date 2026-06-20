# 🛠️ Enterprise Installation, Configuration, and Environment Validation of Prometheus 

## 📋 Comprehensive Lab Guide: End-to-End Infrastructure & Application Monitoring on CentOS

<p align="left">
  <img src="https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=Prometheus&logoColor=white" alt="Prometheus">
  <img src="https://img.shields.io/badge/Linux_CentOS-004A7F?style=for-the-badge&logo=centos&logoColor=white" alt="CentOS">
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
  <img src="https://img.shields.io/badge/Spring_Boot-6DB33F?style=for-the-badge&logo=spring-boot&logoColor=white" alt="Spring Boot">
  <img src="https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=node.js&logoColor=white" alt="Node.js">
  <img src="https://img.shields.io/badge/AWS_EC2-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white" alt="AWS EC2">
</p>

---

## 🗺️ System Architecture

This lab demonstrates an enterprise-grade, pull-based monitoring system architecture. The centralized Prometheus instance scrapes system-level, container-level, and application-level metrics across multiple isolated environments (On-Premise CentOS VMs, Containerized environments via Docker, and Cloud AWS EC2 instances).
<p align="center">
  <img src="./Screenshots/project_diagram.png" width="100%">
  <br>
  <em><b>Figure 1:</b> System Architecture Diagram </em>
</p>

---

## 🛠️ Infrastructure & Tools Matrix

| Tool | Version | Default Port | Role in Architecture |
| --- | --- | --- | --- |
| **Prometheus** | v3.2.1 (Stable) | `9090` | Centralized time-series database & scraping engine |
| **Node Exporter** | v1.8.2 | `9100` | Machine metrics collector (CPU, Memory, Disk, Network) |
| **Python / Flask** | Custom App | `5000` | Simulated microservice exposing custom HTTP counters |
| **Node.js App** | Custom App | `3000` (External) / `8000` (Internal) | Containerized Node.js service exporting native metrics |
| **Java Spring Boot** | Custom App | `8080` (External) / `6666` (Internal) | Microservice exposing Actuator Prometheus telemetry |
| **cAdvisor** | v0.49.1 | `8085` (External) / `8080` (Internal) | Analyzes and exposes resource usage from running containers |
| **Firewalld (CentOS)** | Native | — | Secure perimeter control managing port ingress/egress |

---

## 🚀 Server-by-Server Deployment Guide

### 1️⃣ Server A: Prometheus Core Server (Central Engine)

#### A. Pre-requisites & User Provisioning
Create a dedicated system user account without login shells (`/sbin/nologin`) to safely isolate the Prometheus service process execution context.
```bash
# Ensure download utilities are available
sudo dnf install -y wget tar

# Create system account
sudo useradd --no-create-home --shell /sbin/nologin prometheusservice

# Prepare standard system directories
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

```

#### B. Installation & Storage Setup

Download and unpack the stable v3.2.1 components. Note that legacy console folders (`consoles`/`console_libraries`) are removed in recent modern updates.

```bash
cd /tmp
wget [https://github.com/prometheus/prometheus/releases/download/v3.2.1/prometheus-3.2.1.linux-amd64.tar.gz](https://github.com/prometheus/prometheus/releases/download/v3.2.1/prometheus-3.2.1.linux-amd64.tar.gz)
tar -xvf prometheus-3.2.1.linux-amd64.tar.gz
cd prometheus-3.2.1.linux-amd64

# Move binary files to local executable paths
sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/
sudo cp prometheus.yml /etc/prometheus/

# Adjust Ownership Permissions
sudo chown -R prometheusservice:prometheusservice /etc/prometheus /var/lib/prometheus
sudo chown prometheusservice:prometheusservice /usr/local/bin/prometheus
sudo chown prometheusservice:prometheusservice /usr/local/bin/promtool

```

#### C. Systemd Service Configuration

Configure a native systemd unit file at `/etc/systemd/system/prometheus.service`:

```ini
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheusservice
Group=prometheusservice
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus/

[Install]
WantedBy=multi-user.target

```

#### D. Networking & Service Activation

```bash
# Enable Firewalld rule for dashboard web UI accessibility
sudo firewall-cmd --permanent --add-port=9090/tcp
sudo firewall-cmd --reload

# Reload daemon and run service
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

```

#### 📸 Verification Checklist

* Run `sudo systemctl status prometheus` to check active operational status.

<p align="center">
  <img src="./Screenshots/prometheus_status_check.png" width="100%">
  <br>
  <em><b>Figure 2: </b> Prometheus Status Check </em>
</p>


---

### 2️⃣ Server B & C: Node Exporter Implementation (Other VM & AWS EC2)

*Execute these configuration commands on BOTH targeted compute nodes.*

#### A. User Provisioning & Binary Installation

```bash
# Secure execution context
sudo useradd --no-create-home --shell /sbin/nologin node_exporter

# Fetch Node Exporter binary bundle
cd /tmp
wget [https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz](https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz)
tar -xvf node_exporter-1.8.2.linux-amd64.tar.gz
cd node_exporter-1.8.2.linux-amd64

# Move executables and assign ownership
sudo cp node_exporter /usr/local/bin/
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

```

#### B. Systemd Daemon Deployment

Create the system unit descriptor file at `/etc/systemd/system/node_exporter.service`:

```ini
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target

```

#### C. Network Integration

```bash
# Adjust Firewalld rules for scraper ingress
sudo firewall-cmd --permanent --add-port=9100/tcp
sudo firewall-cmd --reload

# Fire systemd unit
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

```

> ⚠️ **AWS Cloud Network Note:** Ensure the AWS EC2 instance's Security Group allows inbound TCP traffic on port `9100` restricted to the Prometheus Server IP.

#### 📸 Verification Checklist

* Run `sudo systemctl status node_exporter` on both nodes.

<p align="center">
  <img src="./Screenshots/node_exporter_status_check_on_other_vm.png" width="100%">
  <br>
  <em><b>Figure 3:</b> Node Exporter Status Check On Other VM </em>
</p>

<p align="center">
  <img src="./Screenshots/node_exporter_status_check_on_ec2_instance.png" width="100%">
  <br>
  <em><b>Figure 4:</b> Node Exporter Status Check On EC2 Instance </em>
</p>

---

### 3️⃣ Server D: Python Instrumented Application

#### A. Python Dependency Resolution

```bash
sudo dnf install -y python3 python3-pip
pip3 install flask prometheus_client

```

#### B. Application Configuration

```bash
sudo nano python-app.py

```

```python
from flask import Flask, Response
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

requests_total = Counter(
    'app_requests_total',
    'Total requests'
)

@app.route('/')
def home():
    requests_total.inc()
    return "Hello ITI to python app with prometheus monitoring"

@app.route('/metrics')
def metrics():
    return Response(
        generate_latest(),
        mimetype=CONTENT_TYPE_LATEST
    )

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

```

#### C. Activating Application

```bash
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload

# Run the application 
python python-app.py

```

#### 📸 Verification Checklist

* Run `python python-app.py` to ensure application availability.

<p align="center">
  <img src="./Screenshots/application_run_verify.png" width="100%">
  <br>
  <em><b>Figure 5:</b> Application Run Verify</em>
</p>

---

### 4️⃣ Server E: Containerized Environment & Microservices (Docker Node)

#### A. Pre-requisites & Docker Engine Provisioning

Install Docker Engine and Docker Compose Plugin on the targeted CentOS Node.

```bash
# Install base utilities
sudo dnf install -y yum-utils git

# Set up the stable repository
sudo yum-config-manager --add-repo [https://download.docker.com/linux/centos/docker-ce.repo](https://download.docker.com/linux/centos/docker-ce.repo)

# Install Docker packages
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Activate Engine
sudo systemctl start docker
sudo systemctl enable docker

```

#### B. Custom Dockerfile Instrumentation for Node.js App

Since the retrieved Node.js repository lacks a native Dockerfile, a custom containerization layer must be engineered:

```bash
cd ~
git clone https://github.com/HaythamMohamd/nodejs-app-for-prometheus.git
cd nodejs-app-for-prometheus
nano Dockerfile

```

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 8000
CMD ["node", "index.js"]

```

#### C. Multi-Service Declarative Orchestration

Clone the Java Spring Boot source code and provision the orchestrator stack via a unified `docker-compose.yml` configuration at the root directory:

```bash
cd ~
git clone https://github.com/HaythamMohamd/spring-prometheus-demo.git
nano docker-compose.yml

```

```yaml
services:
  # 1. Java Spring Boot Application (Listening internally on 6666)
  java-app:
    build: ./spring-prometheus-demo
    container_name: java-spring-app
    ports:
      - "6666:6666"
    restart: always

  # 2. Node.js Application (Listening internally on 8000)
  nodejs-app:
    build: ./nodejs-app-for-prometheus
    container_name: nodejs-prometheus-app
    ports:
      - "3000:8000"
    restart: always

  # 3. Google cAdvisor (Container Resource Telemetry Engine)
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:v0.49.1
    container_name: cadvisor
    ports:
      - "8085:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    devices:
      - /dev/kmsg
    privileged: true
    restart: always

```

#### D. Operational Deployment & Perimeter Control

```bash
# Deploy stack in detached background mode
sudo docker compose up --build -d

# Open explicit Ingress Paths for Prometheus Scraping Engines
sudo firewall-cmd --permanent --zone=public --add-port=3000/tcp
sudo firewall-cmd --permanent --zone=public --add-port=6666/tcp
sudo firewall-cmd --permanent --zone=public --add-port=8085/tcp
sudo firewall-cmd --reload

```

---

## 🔗 Central Configuration Wiring (`prometheus.yml`)

Update `/etc/prometheus/prometheus.yml` on your central Prometheus Server to point directly to your multi-node topology:

```yaml
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]

  - job_name: 'server_vm'
    static_configs:
      - targets: ['<IP_OF_OTHER_VM>:9100']

  - job_name: 'python_flask_app'
    static_configs:
      - targets: ['<IP_OF_PYTHON_APP_VM>:5000']

  - job_name: 'ec2_node_exporter'
    static_configs:
      - targets: ['<PUBLIC_OR_PRIVATE_IP_OF_EC2>:9100']

  - job_name: 'containerized_nodejs_app'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['<IP_OF_DOCKER_NODE_VM>:3000']

  - job_name: 'containerized_java_spring_boot_app'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['<IP_OF_DOCKER_NODE_VM>:6666']

  - job_name: 'containerized_cadvisor_metrics'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['<IP_OF_DOCKER_NODE_VM>:8085']

```

Apply modifications smoothly:

```bash
sudo systemctl restart prometheus

```

#### 📸 Final Validation Verification

* Navigate to `http://<PROMETHEUS_SERVER_IP>:9090/targets` via browser.

<p align="center">
  <img src="./Screenshots/prometheus_dashboard_verify.png" width="100%">
  <br>
  <em><b>Figure 6:</b> Prometheus Dashboard Verify </em>
</p>

---

## 📝 Project Summary

This enterprise architecture simulation demonstrates a secure and production-ready monitoring ecosystem leveraging Prometheus v3 on CentOS Linux.

### Key Accomplishments:

* **Secured System Access Control:** Isolated all native system daemons using minimal privileges (`/sbin/nologin` users), ensuring strong process isolation.
* **Network Infrastructure Security:** Configured explicit ingress port configurations using native `firewalld` filtering mechanisms along with public cloud security groups.
* **Microservices & Container Telemetry:** Effectively integrated Google cAdvisor alongside runtime environment hooks to continuously map internal app logic out of standard network bridges.
* **Code-Level Alignment:** Identified embedded runtime bindings within source objects (such as Spring Boot Tomcat on port `6666` and Node.js on port `8000`) and correctly unified them across declarative orchestration configurations.
* **Multi-Environment Aggregation:** Combined multi-source hardware footprints (On-Prem VMs + Cloud instances + Containerized Clusters) into a standardized telemetry control interface.

---

**Developed by:** [Eslam Harpy](https://github.com/EslamHarpy)

*Infrastructure & DevOps Engineer*
