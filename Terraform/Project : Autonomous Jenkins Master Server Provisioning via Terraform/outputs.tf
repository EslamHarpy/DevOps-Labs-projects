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