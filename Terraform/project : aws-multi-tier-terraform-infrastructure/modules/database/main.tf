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
  allocated_storage      = 20
  identifier             = "rds-production"
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  auto_minor_version_upgrade = true  
  instance_class         = "db.t3.micro"
  db_name                = "project_rds"
  username               = var.db_username
  password               = var.db_password
  publicly_accessible    = false
  skip_final_snapshot    = true
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = { Name = "ProductionMySQLInstance" }
}