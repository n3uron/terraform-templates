# Standalone-Atlas — Existing VPC
# Usage: tofu -chdir="standalone-atlas" plan -var-file="tests/existing-vpc.tfvars" -var-file="tests/secrets.tfvars"

aws_region          = "eu-south-2"
name_prefix         = "test-sa-atlas-ext"
instance_type       = "t4g.small"
root_volume_size_gb = 8
atlas_instance_size = "M0"
atlas_region_name   = "EU_WEST_1"
atlas_db_username   = "n3uron"
atlas_db_password   = "verysecurepassword"

# Replace with real IDs before applying
existing_vpc_id    = "vpc-0ecd2939bdf7d2161"
existing_subnet_id = "subnet-071f604797343e36e"
