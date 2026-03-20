# Standalone — Existing VPC
# Usage: tofu -chdir="standalone" plan -var-file="tests/existing-vpc.tfvars"

aws_region          = "eu-south-2"
name_prefix         = "test-sa-exist-vpc"
instance_type       = "t4g.small"
root_volume_size_gb = 8

# Replace with real IDs before applying
existing_vpc_id    = "vpc-0ecd2939bdf7d2161"
existing_subnet_id = "subnet-071f604797343e36e"
