resource "aws_vpc" "n3uron_vpc" {
  count = var.existing_vpc_id == null ? 1 : 0

  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.name_prefix}-vpc" }
}

resource "aws_subnet" "n3uron_subnet" {
  count = var.existing_vpc_id == null ? 1 : 0

  vpc_id            = aws_vpc.n3uron_vpc[0].id
  cidr_block        = var.public_subnet_cidr
  availability_zone = local.selected_availability_zone
  lifecycle {
    precondition {
      condition     = local.selected_availability_zone != null
      error_message = "No available Availability Zones were returned for the configured region/profile."
    }
  }

  tags = { Name = "${var.name_prefix}-public-subnet" }
}

resource "aws_internet_gateway" "n3uron_igw" {
  count = var.existing_vpc_id == null ? 1 : 0

  vpc_id = aws_vpc.n3uron_vpc[0].id

  tags = { Name = "${var.name_prefix}-igw" }
}

resource "aws_route_table" "n3uron_rt" {
  count = var.existing_vpc_id == null ? 1 : 0

  vpc_id = aws_vpc.n3uron_vpc[0].id

  tags = { Name = "${var.name_prefix}-public-rt" }
}

resource "aws_route" "internet" {
  count = var.existing_vpc_id == null ? 1 : 0

  route_table_id         = aws_route_table.n3uron_rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.n3uron_igw[0].id
}

resource "aws_route" "tigerdata_peering" {
  count                     = var.ts_vpc_peering && var.existing_vpc_id == null ? 1 : 0
  route_table_id            = aws_route_table.n3uron_rt[0].id
  destination_cidr_block    = var.ts_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.tigerdata[0].id
}

resource "aws_route_table_association" "n3uron_rt_assoc" {
  count = var.existing_vpc_id == null ? 1 : 0

  subnet_id      = aws_subnet.n3uron_subnet[0].id
  route_table_id = aws_route_table.n3uron_rt[0].id
}

data "aws_ec2_managed_prefix_list" "ec2_instance_connect" {
  name = "com.amazonaws.${var.aws_region}.ec2-instance-connect"
}

resource "aws_security_group" "n3uron_sg" {
  name_prefix = "${var.name_prefix}-sg-"
  description = "Security group for standalone EC2 instance"
  vpc_id      = local.vpc_id

  ingress {
    description     = "EC2 Instance Connect"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.ec2_instance_connect.id]
  }

  dynamic "ingress" {
    for_each = length(var.ssh_cidr_blocks) > 0 ? [1] : []
    content {
      description = "Direct SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_cidr_blocks
    }
  }

  dynamic "ingress" {
    for_each = length(var.webui_cidr_blocks) > 0 ? [1] : []
    content {
      description = "N3uron WebUI"
      from_port   = 8003
      to_port     = 8003
      protocol    = "tcp"
      cidr_blocks = var.webui_cidr_blocks
    }
  }

  dynamic "ingress" {
    for_each = length(var.links_cidr_blocks) > 0 ? [1] : []
    content {
      description = "N3uron Links"
      from_port   = 3001
      to_port     = 3001
      protocol    = "tcp"
      cidr_blocks = var.links_cidr_blocks
    }
  }

  dynamic "ingress" {
    for_each = var.extra_ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}-sg" }
}
