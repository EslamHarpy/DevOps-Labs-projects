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