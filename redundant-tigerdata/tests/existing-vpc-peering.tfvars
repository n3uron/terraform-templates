# Redundant-TigerData — Existing VPC + VPC Peering
# Usage: tofu -chdir="redundant-tigerdata" plan -var-file="tests/existing-vpc-peering.tfvars" -var-file="tests/secrets.tfvars"

aws_region          = "eu-south-2"
name_prefix         = "test-rd-tiger-extp"
instance_type       = "t4g.small"
root_volume_size_gb = 8
ts_milli_cpu        = 500
ts_memory_gb        = 2
ts_region_code      = "eu-west-1"
ts_vpc_peering      = true

# Replace with real IDs before applying
existing_vpc_id            = "vpc-0ecd2939bdf7d2161"
existing_subnet_id_primary = "subnet-071f604797343e36e"
existing_subnet_id_backup  = "subnet-0e2b72e10c56924cd"
