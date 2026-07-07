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
    use_lockfile = true # Native locking mechanisms without extra Dynamo layers
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "dev_admin"
}