# Redundant-TigerData — New VPC + VPC Peering
# Usage: tofu -chdir="redundant-tigerdata" plan -var-file="tests/new-vpc-peering.tfvars" -var-file="tests/secrets.tfvars"

aws_region          = "eu-south-2"
name_prefix         = "test-rd-tiger-peer"
instance_type       = "t4g.small"
root_volume_size_gb = 8
ts_milli_cpu        = 500
ts_memory_gb        = 2
ts_region_code      = "eu-west-1"
ts_vpc_peering      = true
