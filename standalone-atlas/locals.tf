locals {
  marketplace_product_code = "cyu8fe3v4xd9urjfdqh1kemcd"

  selected_ami_id            = var.ami_id != null ? var.ami_id : (length(data.aws_ami.marketplace) > 0 ? data.aws_ami.marketplace[0].id : null)
  selected_availability_zone = length(data.aws_availability_zones.available.names) > 0 ? data.aws_availability_zones.available.names[0] : null

  vpc_id    = var.existing_vpc_id != null ? var.existing_vpc_id : aws_vpc.n3uron_vpc[0].id
  subnet_id = var.existing_subnet_id != null ? var.existing_subnet_id : aws_subnet.n3uron_subnet[0].id

  # ── Atlas helpers ───────────────────────────────────────────────────────────
  atlas_region_name = coalesce(var.atlas_region_name, upper(replace(var.aws_region, "-", "_")))
  is_tenant_tier    = contains(["M0", "M2", "M5"], var.atlas_instance_size)
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "marketplace" {
  count       = var.ami_id == null ? 1 : 0
  owners      = ["aws-marketplace"]
  most_recent = true

  filter {
    name   = "product-code"
    values = [local.marketplace_product_code]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
