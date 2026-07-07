# 🚀 Autonomous Jenkins Master Server Provisioning via Terraform 
<p align="left">
  <img src="https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white" alt="AWS"/>
  <img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform"/>
  <img src="https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=jenkins&logoColor=white" alt="Jenkins"/>
  <img src="https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white" alt="Ubuntu"/>
</p>

## 📝 Project Overview
This repository contains the complete Infrastructure as Code (IaC) configuration to fully automate the orchestration, networking, and bootstrapping of a modern, enterprise-ready Jenkins CI/CD Master Server on AWS. 

The environment is strictly modularized, separating networking layers from compute setups. **Crucially, the infrastructure is hardened by design: while global web access is permitted to the Jenkins dashboard, administrative SSH access via Port 22 is strictly locked down and exclusive to the authorized Admin/Developer's specific dynamic IP address**, leveraging automated non-interactive Shell triggers to handle application runtime setup entirely hands-free.

### 🛡️ 2026 Enterprise Best Practices Implemented
* **Robust Blueprint Upgrades**: Engineered on **`t3.medium`** execution architectures to comfortably run modern Java runtimes and prevent JVM Out-Of-Memory (OOM) compilation crashes.
* **Modern Cryptographic Standards**: Upgraded repositories away from deprecated `apt-key add` parameters, utilizing secure ASCII armored keyrings targeting the official **`jenkins.io-2026.key`**.
* **Modern Runtime Matrix**: Provisions **`OpenJDK 21`** directly, matching the strict baseline dependency upgrades enforced by modern Jenkins distributions.
* **Seamless Network Edge Routing**: Automated public IP mapping boundaries explicitly via `map_public_ip_on_launch = true` inside custom subnets to guarantee continuous automated Internet Gateway ingress/egress.
* **Granular Perimeter Security**: Restricts global public ingress strictly to web engine port `8080`, while clamping administrative management port `22` using static single-host developer IP matching (`/32` masking).

---

## 📐 Architecture Diagram

The blueprint below details the structural ingress flow, dynamic mapping limits, and the edge perimeter firewall rules:

<p align="center">
  <img src="./Screenshots/project-diagram" width="100%">
  <br>
  <em><b>Figure 1:</b> Project Architecture</em>
</p>

---

## 📁 Repository Structure

```text
project_root/
├── main.tf                 # Root driver orchestrating network and compute modules
├── variables.tf            # Global scope environment variables
├── providers.tf            # Core AWS provider block & secure remote S3 Backend
├── outputs.tf              # Surface metrics (Static Web URLs & Live IPs)
├── terraform.tfvars        # Sensitive runtime definitions (Developer Host IP)
├── jenkins_installation.sh # Automated non-interactive bootstrapping script
└── modules/
    ├── vpc/
    │   ├── main.tf         # Network assets (VPC, Subnet Route Maps, Ingress IGW)
    │   ├── variables.tf    # VPC module input structural targets
    │   └── outputs.tf      # Exported network IDs for module cross-referencing
    └── jenkins/
        ├── main.tf         # Compute engine definitions (Sec Groups, Key Pair, EC2, EIP)
        ├── variables.tf    # Compute module inputs
        └── outputs.tf      # Exported dynamic server interfaces

```

---

## 🛠️ Technical Stack & Tooling Matrix

| Component | Technology | Operational Function / Best Practice Baseline |
| --- | --- | --- |
| **Orchestration Engine** | Terraform v1.15.0+ | Multi-module dependency tracking, lifecycle scheduling, and declarative state orchestration. |
| **CI/CD Platform** | Jenkins Automation | Enterprise workflow pipeline runner core engine. |
| **Host Environment** | Ubuntu Server 22.04 LTS | Hardened long-term support operating system base target framework. |
| **Runtime Environment** | OpenJDK 21 JRE | Modern platform runtime execution stack matching 2026 Jenkins updates. |
| **State Persistence** | Amazon S3 Bucket | Secured remote infrastructure synchronization layer with automated state locking. |

---
## ⚙️ Pre-Deployment User Configuration

Execute the following setup sequences to prepare your environment authentication vectors before firing up the infrastructure lifecycle:

### 1. Remote S3 State Storage Bucket Initialization

Before initializing Terraform, provision a dedicated Amazon S3 bucket within your targeted AWS region to hold state records. Turn on Server-Side Encryption (SSE) and enable Object Versioning on this bucket to maintain an explicit backup tree of infrastructural adjustments.

### 2. IAM User Creation & Access Management

1. Authenticate into the AWS Administrative Console and open the **IAM Console**.
2. Provision a new operational IAM Identity named `dev_admin`.
3. Apply explicit programmatic permissions policies (`AdministratorAccess` or granular least-privilege policies tailored to S3, EC2, VPC, and RDS lifecycles).
4. Generate an active pair of **Programmatic Access Keys** (Access Key ID and Secret Access Key).

### 3. Client Terminal Authentication Configuration

Establish local client workstation authentication access mappings using your native terminal console:

```bash
# Initialize local AWS credential allocation mapping
aws configure --profile dev_admin

# Complete terminal authentication challenge inputs
# AWS Access Key ID [None]: AKIAXXXXXXXXXXXXXXXX
# AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
# Default region name [None]: us-east-1
# Default output format [None]: json

```

### 4. SSH Keypair Validation Setup

Generate an asymmetric authorization keypair on your deployment workspace host to facilitate secure cluster runtime maintenance:

```bash
ssh-keygen -t rsa -b 4048 -f ~/.ssh/MyKey

```

---

## 🚀 Complete Project Scripts & Manifests

### 📄 1. Bootstrapping Payload (`jenkins_installation.sh`)

```bash
#!/bin/bash
# Enable absolute strict exit rules for automated pipeline debugging
set -euxo pipefail

# Force fully silent package deployments away from interactive configuration dialogs
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

echo "========== Update packages & Install baseline frameworks =========="
apt-get update -y
apt-get install -y \
    ca-certificates \
    curl \
    wget \
    gnupg \
    fontconfig \
    openjdk-21-jre

echo "========== Configure 2026 Secure Jenkins Repository =========="
mkdir -p /etc/apt/keyrings

# Pulling down the modern verified 2026 cryptographic release key
wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  [https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key](https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key)

# Write repository route pointing explicitly to the armored keyring ring asset
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] [https://pkg.jenkins.io/debian-stable](https://pkg.jenkins.io/debian-stable) binary/" \
  > /etc/apt/sources.list.d/jenkins.list

echo "========== Execute Hardened Platform Installation =========="
apt-get update -y
apt-get install -y jenkins

echo "========== Initialize Automation Engine Daemon Processes =========="
systemctl daemon-reload
systemctl enable jenkins
systemctl restart jenkins

echo "========== Automated Lifecycle Execution Log Verify =========="
systemctl status jenkins --no-pager || true

echo "========== Output Initial Administrative Unlock Token =========="
cat /var/lib/jenkins/secrets/initialAdminPassword || true

```

### 📄 2. Root Architecture Orchestrator (`/main.tf`)

```hcl
module "vpc" {
  source             = "./modules/vpc"
  vpc_name           = var.vpc_name
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
}

module "jenkins" {
  source           = "./modules/jenkins"
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_id
  my_ip            = var.my_ip
}

```

### 📄 3. Root Variables (`/variables.tf`)

```hcl
variable "vpc_name" {
  type        = string
  description = "The deployment name for the custom VPC network"
  default     = "jenkins_production_vpc"
}

variable "vpc_cidr" {
  type        = string
  description = "Primary CIDR block for the custom VPC network architecture"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR range allocated specifically for the public tier subnet"
  default     = "10.0.10.0/24"
}

variable "my_ip" {
  type        = string
  description = "Secure external developer IP address for controlled SSH filtering"
  sensitive   = true
}

```

### 📄 4. Root Outputs (`/outputs.tf`)

```hcl
output "deployed_vpc_id" {
  description = "The structurally created AWS Custom VPC Identifier"
  value       = module.vpc.vpc_id
}

output "jenkins_host_public_ip" {
  description = "The production static Elastic IP mapped to the Jenkins Master Node"
  value       = module.jenkins.jenkins_public_ip
}

output "jenkins_management_url" {
  description = "The dynamic web ingress address for Jenkins application initialization"
  value       = "http://${module.jenkins.jenkins_public_ip}:8080"
}

```

### 📄 5. Root Providers & S3 Backend (`/providers.tf`)

```hcl
terraform {
  required_version = ">= 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "harpy-terraform-state-bucket"
    key          = "jenkins-ci-cd/infrastructure.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "dev_admin"
}

```

### 📄 6. Root Environment Values (`/terraform.tfvars`)

```hcl
my_ip = "109.177.94.11"

```

### 📄 7. Modular Network Driver (`/modules/vpc/main.tf`)

```hcl
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = var.vpc_name
    Terraform = "true"
  }
}

data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true # Critical fix to automate dynamic edge internet resolution

  tags = {
    Name      = "${var.vpc_name}-public-subnet"
    Terraform = "true"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "${var.vpc_name}-igw" }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name      = "${var.vpc_name}-public-rtb"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet.id
}

```

### 📄 8. Network Module Variables (`/modules/vpc/variables.tf`)

```hcl
variable "vpc_name" { type = string }
variable "vpc_cidr" { type = string }
variable "public_subnet_cidr" { type = string }

```

### 📄 9. Network Module Outputs (`/modules/vpc/outputs.tf`)

```hcl
output "vpc_id" { value = aws_vpc.vpc.id }
output "public_subnet_id" { value = aws_subnet.public_subnet.id }

```

### 📄 10. Modular Compute Driver (`/modules/jenkins/main.tf`)

```hcl
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-security-group"
  description = "Controlled ingress/egress firewall for Jenkins Engine Master"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow global public web traffic to Jenkins engine dashboard"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Strict single-host developer SSH lock"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    description = "Allow full system outbound routing paths"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "jenkins-server-sg" }
}

resource "aws_key_pair" "my_key" {
  key_name   = "JenkinsDeploymentKey"
  public_key = file("~/.ssh/MyKey.pub")
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "jenkins_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium" # Robust core engine preventing JVM OOM halts
  key_name                    = aws_key_pair.my_key.key_name
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = file("${path.root}/jenkins_installation.sh")

  tags = { Name = "Jenkins_Automation_Master" }
}

resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.jenkins_instance.id
  domain   = "vpc"

  tags = { Name = "jenkins-static-eip" }
}

```

### 📄 11. Compute Module Variables (`/modules/jenkins/variables.tf`)

```hcl
variable "vpc_id" { type = string }
variable "public_subnet_id" { type = string }
variable "my_ip" { type = string }

```

### 📄 12. Compute Module Outputs (`/modules/jenkins/outputs.tf`)

```hcl
output "jenkins_public_ip" { value = aws_eip.jenkins_eip.public_ip }

```

---

## ⚙️ Execution & Lifecycle Commands

1. **Verify Your Local Key-Pair Token Asset**:
```bash
ssh-keygen -t rsa -b 4048 -f ~/.ssh/MyKey

```


2. **Input Local Variable State Runtime Values (`/terraform.tfvars`)**:
```hcl
my_ip = "YOUR_LIVE_PUBLIC_WAN_IP_ADDRESS"

```


3. **Execute the Structural Automation Pipeline**:
```bash
terraform init
terraform plan
terraform apply --auto-approve

```



---

## 🔍 Structural Verification Pipeline

Once the Terraform execution completes, utilize the terminal outputs to perform system handshakes and verify service availability:

### 1. Web Dashboard Ingress Verification

Open your local web browser engine and target the output mapped web address parameter:

```text
http://<YOUR_JENKINS_MASTER_PUBLIC_IP>:8080

```

*Expected Behavior:* The system rendering layer loads up the **"Unlock Jenkins"** setup wizard payload interface.
<p align="center">
  <img src="./Screenshots/web-verify.png" width="100%">
  <br>
  <em><b>Figure 2:</b> Jenkins Dashboard Verify </em>
</p>
### 2. Administrative Security Handshake via SSH

Establish a secure connection vector directly through your system workspace command terminal interface:

```bash
ssh -i ~/.ssh/MyKey ubuntu@<YOUR_JENKINS_MASTER_PUBLIC_IP>

```
<p align="center">
  <img src="./Screenshots/ssh-verify.png" width="100%">
  <br>
  <em><b>Figure 3:</b> SSH Verify </em>
</p>

### 3. Execution Log Auditing & Verification

Inside the remote master host prompt, verify package status loops and pull down the automated administrative security passphrase directly:

```bash
# Audit cloud-init initialization logs to check execution performance output
cat /var/log/cloud-init-output.log

# Read active runtime status maps directly via systemd engine
sudo systemctl status jenkins

# Extract the secret admin setup initialization unlock string passphrase
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

```

Copy the emitted string payload block directly into the initialization browser panel window interface, choose **"Install Suggested Plugins"**, and start orchestrating your Continuous Delivery engines!

---
## 👨‍💻 Engineering Author

**Developed by:** [Eslam Harpy](https://github.com/EslamHarpy)

*Infrastructure & DevOps Engineer*

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/eslamharpy05/)

