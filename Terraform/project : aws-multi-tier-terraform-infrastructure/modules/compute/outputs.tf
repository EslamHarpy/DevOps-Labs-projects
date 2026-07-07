output "web_sg_id" {
  value = aws_security_group.web_sg.id
}

output "alb_dns_name" {
  value = aws_lb.web_app_alb.dns_name
}