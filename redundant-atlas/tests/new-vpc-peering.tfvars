# Redundant-Atlas — New VPC + VPC Peering
# Usage: tofu -chdir="redundant-atlas" plan -var-file="tests/new-vpc-peering.tfvars" -var-file="tests/secrets.tfvars"

aws_region          = "eu-south-2"
name_prefix         = "test-rd-atlas-peer"
instance_type       = "t4g.small"
root_volume_size_gb = 8
atlas_instance_size = "M10"
atlas_vpc_peering   = true
atlas_db_username   = "n3uron"
atlas_db_password   = "verysecurepassword"
