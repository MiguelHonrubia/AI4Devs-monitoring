# EC2 Instance Outputs
output "backend_instance_id" {
  description = "ID of the backend EC2 instance"
  value       = aws_instance.backend.id
}

output "frontend_instance_id" {
  description = "ID of the frontend EC2 instance"
  value       = aws_instance.frontend.id
}

output "backend_public_ip" {
  description = "Public IP of the backend instance"
  value       = aws_instance.backend.public_ip
}

output "frontend_public_ip" {
  description = "Public IP of the frontend instance"
  value       = aws_instance.frontend.public_ip
}

# Datadog Integration Outputs
output "datadog_integration_external_id" {
  description = "External ID for AWS-Datadog integration"
  value       = data.datadog_integration_aws_external_id.external_id.external_id
  sensitive   = true
}

output "datadog_role_arn" {
  description = "ARN of the IAM role for Datadog integration"
  value       = aws_iam_role.datadog_aws_integration.arn
}

output "datadog_dashboard_url" {
  description = "URL of the Datadog dashboard"
  value       = "https://app.${var.datadog_site}/dashboard/${datadog_dashboard.aws_infrastructure.id}"
}

# Application URLs
output "backend_url" {
  description = "Backend application URL"
  value       = "http://${aws_instance.backend.public_ip}:8080"
}

output "frontend_url" {
  description = "Frontend application URL"
  value       = "http://${aws_instance.frontend.public_ip}"
}

# Configuration Instructions
output "setup_instructions" {
  description = "Instructions for completing the setup"
  value = <<EOF

🚀 SETUP COMPLETED! 

Next steps:
1. Wait 5-10 minutes for instances to fully boot and agents to start reporting
2. Visit your Datadog dashboard: https://app.${var.datadog_site}/dashboard/${datadog_dashboard.aws_infrastructure.id}
3. Check your infrastructure in Datadog: https://app.${var.datadog_site}/infrastructure
4. Backend API: http://${aws_instance.backend.public_ip}:8080
5. Frontend App: http://${aws_instance.frontend.public_ip}

📊 Monitoring Features Enabled:
- AWS CloudWatch integration
- Datadog agent on all instances
- Docker container monitoring
- System metrics (CPU, Memory, Disk, Network)
- Custom dashboard with key metrics
- Automated alerts for high resource usage
- Process monitoring
- Log collection

🔧 Troubleshooting:
- SSH into instances to check Datadog agent: sudo systemctl status datadog-agent
- Check agent logs: sudo tail -f /var/log/datadog/agent.log
- Verify CloudWatch agent: sudo systemctl status amazon-cloudwatch-agent

EOF
} 