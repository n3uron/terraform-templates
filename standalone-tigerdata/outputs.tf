output "public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = aws_eip.n3uron_eip.public_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance."
  value       = aws_eip.n3uron_eip.public_dns
}

output "instance_id" {
  description = "EC2 instance ID. This is the one-time initial password for the N3uron WebUI."
  value       = aws_instance.n3uron_ec2.id
}

output "private_dns" {
  description = "Private DNS name of the EC2 instance."
  value       = aws_instance.n3uron_ec2.private_dns
}

output "vpc_id" {
  description = "VPC ID."
  value       = local.vpc_id
}

output "n3uron_web_url" {
  description = "N3uron WebUI URL."
  value       = "http://${aws_eip.n3uron_eip.public_dns}:8003"
}

# --- Connection methods (in order of preference) ---

output "connect_via_console" {
  description = "Connect via EC2 Instance Connect in the AWS Console (preferred)."
  value       = "https://${var.aws_region}.console.aws.amazon.com/ec2-instance-connect/ssh?connType=standard&instanceId=${aws_instance.n3uron_ec2.id}&osUser=ubuntu&sshPort=22&region=${var.aws_region}"
}

output "connect_via_cli" {
  description = "Connect via EC2 Instance Connect CLI (no key pair needed)."
  value       = "aws ec2-instance-connect ssh --instance-id ${aws_instance.n3uron_ec2.id} --os-user ubuntu --region ${var.aws_region}"
}

output "connect_via_ssm" {
  description = "Connect via SSM Session Manager (no key pair needed)."
  value       = "aws ssm start-session --target ${aws_instance.n3uron_ec2.id} --region ${var.aws_region}"
}

output "connect_via_ssh" {
  description = "Connect via direct SSH (requires a key pair)."
  value       = var.key_name != null && length(var.ssh_cidr_blocks) > 0 ? "ssh -i <path-to-${var.key_name}.pem> ubuntu@${aws_eip.n3uron_eip.public_dns}" : null
}

# ── TigerData (Timescale Cloud) ──────────────────────────────────────────────

output "tigerdata_service_id" {
  description = "TigerData service ID in Timescale Cloud."
  value       = timescale_service.tigerdata.id
}

output "tigerdata_uri" {
  description = "PostgreSQL connection URI for the TigerData service."
  value       = "postgresql://${timescale_service.tigerdata.username}:${timescale_service.tigerdata.password}@${timescale_service.tigerdata.hostname}:${timescale_service.tigerdata.port}/tsdb?sslmode=require"
  sensitive   = true
}

output "tigerdata_vpc_peering_id" {
  description = "VPC peering connection ID between AWS and Timescale Cloud."
  value       = var.ts_vpc_peering ? aws_vpc_peering_connection_accepter.tigerdata[0].id : null
}
