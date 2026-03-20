# Redundant-Atlas — Existing VPC + VPC Peering
# Usage: tofu -chdir="redundant-atlas" plan -var-file="tests/existing-vpc-peering.tfvars" -var-file="tests/secrets.tfvars"

aws_region          = "eu-south-2"
name_prefix         = "test-rd-atlas-extp"
instance_type       = "t4g.small"
root_volume_size_gb = 8
atlas_instance_size = "M10"
atlas_vpc_peering   = true
atlas_db_username   = "n3uron"
atlas_db_password   = "verysecurepassword"

# Replace with real IDs before applying
existing_vpc_id            = "vpc-0ecd2939bdf7d2161"
existing_subnet_id_primary = "subnet-071f604797343e36e"
existing_subnet_id_backup  = "subnet-0e2b72e10c56924cd"
