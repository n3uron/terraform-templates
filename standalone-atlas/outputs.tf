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

# ── MongoDB Atlas ─────────────────────────────────────────────────────────────

output "atlas_cluster_id" {
  description = "MongoDB Atlas cluster ID."
  value       = mongodbatlas_advanced_cluster.this.cluster_id
}

output "atlas_cluster_state" {
  description = "Current state of the Atlas cluster (IDLE, CREATING, etc.)."
  value       = mongodbatlas_advanced_cluster.this.state_name
}

output "atlas_connection_string_srv" {
  description = "MongoDB Atlas connection string (SRV format)."
  value       = mongodbatlas_advanced_cluster.this.connection_strings.standard_srv
}

output "atlas_connection_string_standard" {
  description = "MongoDB Atlas connection string (standard format)."
  value       = mongodbatlas_advanced_cluster.this.connection_strings.standard
}

output "atlas_db_username" {
  description = "MongoDB Atlas database username."
  value       = mongodbatlas_database_user.this.username
}

output "atlas_vpc_peering_id" {
  description = "VPC peering connection ID between AWS and MongoDB Atlas."
  value       = var.atlas_vpc_peering ? aws_vpc_peering_connection_accepter.atlas[0].id : null
}
