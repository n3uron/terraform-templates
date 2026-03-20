# Standalone — New VPC (default)
# Usage: tofu -chdir="standalone" plan -var-file="tests/new-vpc.tfvars"

aws_region          = "eu-south-2"
name_prefix         = "test-sa-new-vpc"
instance_type       = "t4g.small"
root_volume_size_gb = 8
