# --- Primary instance ---

output "public_ip_primary" {
  description = "Public IP address of the primary EC2 instance."
  value       = aws_eip.primary.public_ip
}

output "public_dns_primary" {
  description = "Public DNS name of the primary EC2 instance."
  value       = aws_eip.primary.public_dns
}

output "instance_id_primary" {
  description = "Primary EC2 instance ID. This is the one-time initial password for the N3uron WebUI."
  value       = aws_instance.primary.id
}

output "private_dns_primary" {
  description = "Private DNS name of the primary EC2 instance. Use this address to configure N3uron redundancy on the backup node."
  value       = aws_instance.primary.private_dns
}

output "n3uron_web_url_primary" {
  description = "N3uron WebUI URL for primary instance."
  value       = "http://${aws_eip.primary.public_dns}:8003"
}

output "connect_via_console_primary" {
  description = "Connect to primary via EC2 Instance Connect in the AWS Console (preferred)."
  value       = "https://${var.aws_region}.console.aws.amazon.com/ec2-instance-connect/ssh?connType=standard&instanceId=${aws_instance.primary.id}&osUser=ubuntu&sshPort=22&region=${var.aws_region}"
}

output "connect_via_cli_primary" {
  description = "Connect to primary via EC2 Instance Connect CLI (no key pair needed)."
  value       = "aws ec2-instance-connect ssh --instance-id ${aws_instance.primary.id} --os-user ubuntu --region ${var.aws_region}"
}

output "connect_via_ssm_primary" {
  description = "Connect to primary via SSM Session Manager (no key pair needed)."
  value       = "aws ssm start-session --target ${aws_instance.primary.id} --region ${var.aws_region}"
}

output "connect_via_ssh_primary" {
  description = "Connect to primary via direct SSH (requires a key pair)."
  value       = var.key_name != null && length(var.ssh_cidr_blocks) > 0 ? "ssh -i <path-to-${var.key_name}.pem> ubuntu@${aws_eip.primary.public_dns}" : null
}

# --- Backup instance ---

output "public_ip_backup" {
  description = "Public IP address of the backup EC2 instance."
  value       = aws_eip.backup.public_ip
}

output "public_dns_backup" {
  description = "Public DNS name of the backup EC2 instance."
  value       = aws_eip.backup.public_dns
}

output "instance_id_backup" {
  description = "Backup EC2 instance ID. This is the one-time initial password for the N3uron WebUI."
  value       = aws_instance.backup.id
}

output "n3uron_web_url_backup" {
  description = "N3uron WebUI URL for backup instance."
  value       = "http://${aws_eip.backup.public_dns}:8003"
}

output "connect_via_console_backup" {
  description = "Connect to backup via EC2 Instance Connect in the AWS Console (preferred)."
  value       = "https://${var.aws_region}.console.aws.amazon.com/ec2-instance-connect/ssh?connType=standard&instanceId=${aws_instance.backup.id}&osUser=ubuntu&sshPort=22&region=${var.aws_region}"
}

output "connect_via_cli_backup" {
  description = "Connect to backup via EC2 Instance Connect CLI (no key pair needed)."
  value       = "aws ec2-instance-connect ssh --instance-id ${aws_instance.backup.id} --os-user ubuntu --region ${var.aws_region}"
}

output "connect_via_ssm_backup" {
  description = "Connect to backup via SSM Session Manager (no key pair needed)."
  value       = "aws ssm start-session --target ${aws_instance.backup.id} --region ${var.aws_region}"
}

output "connect_via_ssh_backup" {
  description = "Connect to backup via direct SSH (requires a key pair)."
  value       = var.key_name != null && length(var.ssh_cidr_blocks) > 0 ? "ssh -i <path-to-${var.key_name}.pem> ubuntu@${aws_eip.backup.public_dns}" : null
}

# --- Shared ---

output "vpc_id" {
  description = "VPC ID."
  value       = local.vpc_id
}

output "subnet_id_primary" {
  description = "Primary public subnet ID."
  value       = local.subnet_id_primary
}

output "subnet_id_backup" {
  description = "Backup public subnet ID."
  value       = local.subnet_id_backup
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
