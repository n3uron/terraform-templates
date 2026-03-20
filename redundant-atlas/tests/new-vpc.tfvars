# Redundant-Atlas — New VPC (default)
# Usage: tofu -chdir="redundant-atlas" plan -var-file="tests/new-vpc.tfvars" -var-file="tests/secrets.tfvars"

aws_region          = "eu-south-2"
name_prefix         = "test-rd-atlas-new"
instance_type       = "t4g.small"
root_volume_size_gb = 8
atlas_instance_size = "M0"
atlas_region_name   = "EU_WEST_1"
atlas_db_username   = "n3uron"
atlas_db_password   = "verysecurepassword"
