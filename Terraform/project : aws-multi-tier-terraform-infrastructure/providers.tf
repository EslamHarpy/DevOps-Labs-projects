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
    use_lockfile = true # Native state locking without DynamoDB
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "dev_admin"
}
