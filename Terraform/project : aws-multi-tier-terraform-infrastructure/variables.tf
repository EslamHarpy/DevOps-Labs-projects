variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = map(string)
  default = {
    "us-east-1a" = "10.0.10.0/24"
    "us-east-1b" = "10.0.20.0/24"
  }
}

variable "private_subnets" {
  type    = map(string)
  default = {
    "us-east-1a" = "10.0.100.0/24"
    "us-east-1b" = "10.0.200.0/24"
  }
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}
