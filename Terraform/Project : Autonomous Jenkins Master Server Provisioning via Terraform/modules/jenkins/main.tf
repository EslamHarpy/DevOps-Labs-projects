# 1. Security Group Configuration
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-security-group"
  description = "Controlled firewall for Jenkins Server"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow web traffic to Jenkins engine"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Strict SSH ingress restriction"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    description = "Allow full system outbound routing"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "jenkins-server-sg" }
}

# 2. Key Pair Configuration
resource "aws_key_pair" "my_key" {
  key_name   = "JenkinsDeploymentKey"
  public_key = file("~/.ssh/MyKey.pub")
}

# 3. AMI Data Source for Ubuntu 22.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

# 4. EC2 Instance Configuration
resource "aws_instance" "jenkins_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
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

# 5. Elastic IP Configuration
resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.jenkins_instance.id
  domain   = "vpc"

  tags = { Name = "jenkins-static-eip" }
}