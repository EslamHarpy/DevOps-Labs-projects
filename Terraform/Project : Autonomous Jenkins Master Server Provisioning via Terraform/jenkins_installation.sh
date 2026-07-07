#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

echo "========== Update packages =========="
apt-get update -y
apt-get install -y \
    ca-certificates \
    curl \
    wget \
    gnupg \
    fontconfig \
    openjdk-21-jre

echo "========== Configure Jenkins repository =========="
mkdir -p /etc/apt/keyrings

wget -O /etc/apt/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
> /etc/apt/sources.list.d/jenkins.list

echo "========== Install Jenkins =========="
apt-get update -y
apt-get install -y jenkins

echo "========== Enable Jenkins =========="
systemctl daemon-reload
systemctl enable jenkins
systemctl restart jenkins

echo "========== Jenkins Status =========="
systemctl status jenkins --no-pager || true

echo "========== Initial Admin Password =========="
cat /var/lib/jenkins/secrets/initialAdminPassword || true