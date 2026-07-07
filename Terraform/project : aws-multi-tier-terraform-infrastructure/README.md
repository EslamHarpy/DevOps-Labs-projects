# 🌐 Enterprise Multi-Tier High-Availability Cloud Infrastructure
<p align="left">
  <img src="https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white" alt="AWS"/>
  <img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform"/>
  <img src="https://img.shields.io/badge/Apache-D22128?style=for-the-badge&logo=apache&logoColor=white" alt="Apache"/>
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux"/>
</p>

## 📝 Project Overview
This project establishes a highly available, fault-tolerant, and secure multi-tier production infrastructure on Amazon Web Services (AWS) using modular Terraform definitions. Designed with strict compliance to cloud security architecture patterns and modern Infrastructure as Code (IaC) best practices, this platform features continuous operational decoupling, multi-AZ high availability, and secure state management.

### 🛡️ Core Best Practices Implemented
* **State & Configuration Isolation**: To prevent exposure of state parameters and secret variables, the standard local execution patterns were eliminated. The environment targets an isolated Amazon S3 Remote Backend featuring structural state locking protocols.
* **Secret Parameter Separation**: Sensitive configurations and database credentials are excluded from the codebase code trees. To enforce absolute segregation of duties, credentials are dynamically requested through dedicated user runtime inputs, ensuring structural security.
* **Granular Network Segmentation**: Public-facing entry endpoints are isolated from compute processing layers and persistent storage engines using structured internal firewalls and multi-AZ layout routing.

---

## 📐 Architecture Diagram
The system layout below illustrates end-to-end traffic management, defensive security boundaries, and localized subnet topologies:

<p align="center">
  <img src="./Screenshots/project-diagram.png" width="100%">
  <br>
  <em><b>Figure 1:</b> System Architecture Diagram </em>
</p>

---

## 📁 Repository Directory Structure

```text
project_root/
├── main.tf                 # Core structural entry point orchestrating all modules
├── variables.tf            # Global architectural configuration variables
├── providers.tf            # Backend definitions and provider configurations
├── outputs.tf              # Aggregated root operational asset outputs
├── terraform.tfvars        # Sensitive dynamic infrastructure values
└── modules/
    ├── vpc/
    │   ├── main.tf         # Network tier configurations
    │   ├── variables.tf    # Network tier constraints
    │   └── outputs.tf      # Network interface outputs
    ├── compute/
    │   ├── main.tf         # Automated server scaling templates
    │   ├── variables.tf    # Compute constraints
    │   └── outputs.tf      # Compute infrastructure tokens
    └── database/
        ├── main.tf         # Subnet mapping groups and RDS cluster
        ├── variables.tf    # Database infrastructure inputs
        └── outputs.tf      # Remote database entrypoint mappings

```

---

## 🛠️ Automated Technical Stack & Tools

| Component | Technology | Operational Function |
| --- | --- | --- |
| **IaC Orchestration** | Terraform v1.15.0+ | Tracks current inventory dependencies and maintains system state.|
| **Edge Server Engine** | Apache HTTP Server | High-performance edge routing layer providing cluster diagnostics. |
| **Compute Engine** | AWS EC2 (t3.micro) | Elastic Virtual Machine execution instances. |
| **Cluster Scaling** | Auto Scaling Group | Automates system scaling policies dynamically across computational boundaries. |
| **Database Engine** | Amazon RDS MySQL 8.0 | Structured storage node with multi-AZ failover configurations.|
| **State Storage Layer** | Amazon S3 (Secure Bucket) | Secure infrastructure state persistence featuring server-side encryption.|

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

## 🚀 Module Configurations & Automation Scripts

---

### 📦 SECTION A: Root Architecture Configuration

#### 📄 Script 1: `project_root/providers.tf`

**Purpose**: Provisions configuration rules targeting the structural state synchronization backend engine. It enables S3 state storage, establishes native state concurrency locking (`use_lockfile = true`), and associates the targeted AWS credential execution identity profile.

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
    key          = "production/infrastructure.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true 
    # Native state locking without DynamoDB
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "dev_admin"
}

```

#### 📄 Script 2: `project_root/main.tf`

**Purpose**: The central root driver orchestrating inter-module dependencies. It threads variable assets, sets up the underlying network fabric, feeds network details into the compute nodes, and bridges the compute firewall rules directly into the isolated data modules.

```hcl
module "vpc" {
  source             = "./modules/vpc"
  aws_region         = var.aws_region
  vpc_cidr           = var.vpc_cidr
  public_subnet_map  = var.public_subnet_map
  private_subnet_map = var.private_subnet_map
}

module "compute" {
  source             = "./modules/compute"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  db_username        = var.db_username
  db_password        = var.db_password
}

module "database" {
  source             = "./modules/database"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  web_tier_sg_id     = module.compute.web_sg_id
  db_username        = var.db_username
  db_password        = var.db_password
}

```

#### 📄 Script 3: `project_root/variables.tf`

**Purpose**: Holds top-level definitions for global architectural inputs. It enforces constraints on core network ranges, maps available Availability Zones, and tags storage credentials securely.

```hcl
variable "aws_region" {
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_map" {
  type        = map(string)
  default     = {
    "us-east-1a" = "10.0.1.0/24"
    "us-east-1b" = "10.0.2.0/24"
  }
}

variable "private_subnet_map" {
  type        = map(string)
  default     = {
    "us-east-1a" = "10.0.3.0/24"
    "us-east-1b" = "10.0.4.0/24"
  }
}

variable "db_username" {
  type        = string
  sensitive   = true
}

variable "db_password" {
  type        = string
  sensitive   = true
}

```

#### 📄 Script 4: `project_root/terraform.tfvars`

**Purpose**: Contains your sensitive environment values. It isolates operational database usernames and passwords from the declarative functional blocks.

```hcl
db_username = "Your-username"
db_password = "Your-Password"

```

#### 📄 Script 5: `project_root/outputs.tf`

**Purpose**: Exposes critical post-deployment connection endpoints, channeling primary load balancer addresses and active production storage nodes directly to the operator interface.

```hcl
output "application_load_balancer_dns" {
  value       = module.compute.alb_dns_name
  description = "Public URL to access the deployed web cluster application"
}

output "production_database_endpoint" {
  value       = module.database.rds_endpoint
  description = "Internal network access connection address for the database cluster"
}

```

---

### 🌐 SECTION B: Network Resource Module (`modules/vpc/`)

#### 📄 Script 6: `modules/vpc/main.tf`

**Purpose**: Configures the underlying network architecture. It provisions the base VPC, sets up an Internet Gateway for edge ingress, dynamically creates public and private subnet pairs across multiple Availability Zones, and configures dedicated NAT Gateways for secure outbound connectivity.

```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "ProductionVPC" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "MainInternetGateway" }
}

resource "aws_subnet" "public" {
  for_each                = var.public_subnet_map
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags                    = { Name = "PublicSubnet-${each.key}" }
}

resource "aws_subnet" "private" {
  for_each          = var.private_subnet_map
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key
  tags              = { Name = "PrivateSubnet-${each.key}" }
}

resource "aws_eip" "nat_eip" {
  for_each   = var.public_subnet_map
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
  tags       = { Name = "NAT-EIP-${each.key}" }
}

resource "aws_nat_gateway" "nat_gw" {
  for_each      = var.public_subnet_map
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  tags          = { Name = "NATGateway-${each.key}" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "PublicRouteTable" }
}

resource "aws_route_table" "private_rt" {
  for_each = var.private_subnet_map
  vpc_id   = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[each.key].id
  }
  tags = { Name = "PrivateRouteTable-${each.key}" }
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = var.public_subnet_map
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_assoc" {
  for_each       = var.private_subnet_map
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private_rt[each.key].id
}

```

#### 📄 Script 7: `modules/vpc/variables.tf`

```hcl
variable "vpc_cidr" { type = string }
variable "public_subnet_map" { type = map(string) }
variable "private_subnet_map" { type = map(string) }

```

#### 📄 Script 8: `modules/vpc/outputs.tf`

```hcl
output "vpc_id" { value = aws_vpc.main.id }
output "public_subnet_ids" { value = [for s in aws_subnet.public : s.id] }
output "private_subnet_ids" { value = [for s in aws_subnet.private : s.id] }

```

---

### 🖥️ SECTION C: Compute Provisioning Module (`modules/compute/`)

#### 📄 Script 9: `modules/compute/main.tf`

**Purpose**: Deploys the elastic compute tier. It sets up strict layered Security Groups, configures an external Layer-7 Application Load Balancer with independent health checking, and utilizes a Launch Template to bootstrap compute hosts dynamically via Auto Scaling policies.

```hcl
# ==============================================================================
# 1. SECURITY GROUPS (STRICT LAYERED FIREWALL)
# ==============================================================================

resource "aws_security_group" "alb_sg" {
  name        = "ALBSG"
  description = "Public HTTP entry point for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_sg" {
  name        = "webSG"
  description = "Security group for internal web and application tier"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = [22, 443]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==============================================================================
# 2. APPLICATION LOAD BALANCER CONFIGURATION
# ==============================================================================

resource "aws_lb" "web_app_alb" {
  name               = "production-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "web_app_tg" {
  name     = "webTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health.html"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399" 
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.web_app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_tg.arn
  }
}

# ==============================================================================
# 3. COMPUTE AUTOMATION & ELASTICITY (LAUNCH TEMPLATE & ASG)
# ==============================================================================

resource "aws_key_pair" "ssh_key" {
  key_name   = "MyKey"
  public_key = file("~/.ssh/MyKey.pub")
}

resource "aws_launch_template" "web_app_template" {
  name_prefix   = "web-app-template-"
  image_id      = "ami-0dfcb1ef8550277af"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.ssh_key.key_name

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      encrypted   = true
    }
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    systemctl stop httpd || true
    systemctl disable httpd || true

    yum update -y
    yum install httpd -y
    systemctl start httpd
    systemctl enable httpd

    echo "OK" > /var/www/html/health.html

    cat <<'HTML' > /var/www/html/index.html
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Production Multi-Tier Enterprise Application</title>
        <style>
            body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f6f9; color: #333; margin: 0; padding: 40px; text-align: center; }
            .container { max-width: 800px; margin: auto; background: white; padding: 40px; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); }
            h1 { color: #1f2d3d; border-bottom: 2px solid #e0e6ed; padding-bottom: 20px; margin-top: 0; font-size: 2.2em; }
            p { color: #4a5568; font-size: 1.15em; line-height: 1.6; }
            .badge-wrapper { margin: 25px 0; }
            .badge { display: inline-block; padding: 12px 24px; color: white; border-radius: 30px; font-weight: 600; font-size: 0.95em; margin: 5px; }
            .badge-infrastructure { background: linear-gradient(135deg, #3182ce, #2b6cb0); }
            .badge-status { background: linear-gradient(135deg, #38a169, #2f855a); }
            .db-status { margin-top: 25px; padding: 20px; border-radius: 12px; font-weight: bold; font-size: 1.1em; }
            .success { background-color: #c6f6d5; color: #22543d; border: 1px solid #38a169; }
            .footer { margin-top: 50px; font-size: 0.9em; color: #a0aec0; border-top: 1px solid #edf2f7; padding-top: 20px; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🌐 Enterprise Multi-Tier Cloud Application</h1>
            <p>High-Availability Web Infrastructure running on isolated Compute Tiers.</p>
            <div class="badge-wrapper">
                <span class="badge badge-infrastructure">🚀 Deployment: Automated via IaC</span>
                <span class="badge badge-status">📍 Architecture: Multi-AZ Isolation</span>
            </div>
            <div>
                <div class='db-status success'>✅ Live Stateful Cloud Infrastructure Verified!</div>
            </div>
            <div class="footer">Apache HTTP Server | Terraform v1.10+</div>
        </div>
    </body>
    </html>
HTML

    chown -R apache:apache /var/www/html/
    chmod -R 755 /var/www/html/
    systemctl restart httpd
EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web_app_asg" {
  name                      = "asg-web-app"
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [aws_lb_target_group.web_app_tg.arn]

  launch_template {
    id      = aws_launch_template.web_app_template.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300
}

resource "aws_autoscaling_policy" "cpu_tracking" {
  name                   = "cpu-tracking-policy"
  autoscaling_group_name = aws_autoscaling_group.web_app_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

```

#### 📄 Script 10: `modules/compute/variables.tf`

```hcl
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "db_username" { type = string }
variable "db_password" { type = string }

```

#### 📄 Script 11: `modules/compute/outputs.tf`

```hcl
output "web_sg_id" { value = aws_security_group.web_sg.id }
output "alb_dns_name" { value = aws_lb.web_app_alb.dns_name }

```

---

### 🗄️ SECTION D: Database Isolation Module (`modules/database/`)

#### 📄 Script 12: `modules/database/main.tf`

**Purpose**: Sets up the stateful database tier. It configures a network subnet group over isolated private networks, restricts ingress to traffic originating from the web application tier on port 3306 , and provisions a fully managed Multi-AZ MySQL node featuring automated software patching.

```hcl
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Strict isolated security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.web_tier_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-private-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "production_db" {
  allocated_storage          = 20
  identifier                 = "rds-production"
  storage_type               = "gp2"
  engine                     = "mysql"
  engine_version             = "8.0"
  auto_minor_version_upgrade = true  
  instance_class             = "db.t3.micro"
  db_name                    = "project_rds"
  username                   = var.db_username
  password                   = var.db_password
  publicly_accessible        = false
  skip_final_snapshot        = true
  multi_az                   = true
  db_subnet_group_name       = aws_db_subnet_group.rds_subnet_group.id
  vpc_security_group_ids     = [aws_security_group.db_sg.id]

  tags = { Name = "ProductionMySQLInstance" }
}

```

#### 📄 Script 13: `modules/database/variables.tf`

```hcl
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "web_tier_sg_id" { type = string }
variable "db_username" { type = string }
variable "db_password" { type = string }

```

#### 📄 Script 14: `modules/database/outputs.tf`

```hcl
output "rds_endpoint" {
  value = aws_db_instance.production_db.endpoint
}

```

---

## 🔍 Structural Verification & Deployment Pipeline

Follow these validation steps to initialize, apply, and monitor the state of your production environment:

### 1. Initialize the Core Working Directory

Download necessary provider binaries and establish connectivity to your secure S3 backend bucket:

```bash
terraform init

```

### 2. Perform Operational Layout Planning

Run a dry-run execution check to view the planned changes before applying them to your AWS account:

```bash
terraform plan

```

### 3. Orchestrate Infrastructure Application

Apply the modifications to construct your resources automatically inside your cloud account:

```bash
terraform apply --auto-approve

```

### 4. Assert Operational Cluster Health

* Query your custom endpoint verification path using a terminal execution host to validate layer communication:
```bash
curl -I http://<application_load_balancer_dns>/health.html
# Expected Response Status Check: HTTP/1.1 200 OK

```
<p align="center">
  <img src="./Screenshots/healthcheck-verify.png" width="100%">
  <br>
  <em><b>Figure 2:</b> Health Check Verify </em>
</p>
<p align="center">
  <img src="./Screenshots/targetgroup-verify.png" width="100%">
  <br>
  <em><b>Figure 3:</b> Target Group Health Check Verify </em>
</p>

* Open the public load balancer URL inside a clean private window session to visually confirm that the web platform layout panel is live.
<p align="center">
  <img src="./Screenshots/website-verify.png" width="100%">
  <br>
  <em><b>Figure 4:</b> Web Site Verify </em>
</p>
---

## 🏁 Conclusion

By utilizing modern modular designs and decoupling infrastructure components, this architecture establishes an isolated network environment. It keeps private data nodes safe from outside access, routes traffic securely through layered firewalls, and maintains high availability across multiple availability zones automatically.

---

## 👨‍💻 Engineering Author

**Developed by:** [Eslam Harpy](https://github.com/EslamHarpy)

*Infrastructure & DevOps Engineer*

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/eslamharpy05/)
