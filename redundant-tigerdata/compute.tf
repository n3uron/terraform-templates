resource "aws_instance" "primary" {
  ami                    = local.selected_ami_id
  instance_type          = var.instance_type
  subnet_id              = local.subnet_id_primary
  vpc_security_group_ids = [aws_security_group.n3uron_sg.id, aws_security_group.n3uron_redundancy.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.n3uron_ec2.name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size_gb
    encrypted   = var.root_volume_encrypted
  }

  lifecycle {
    precondition {
      condition     = local.selected_ami_id != null
      error_message = "Set ami_id or ensure the hardcoded Marketplace product code resolves an AMI in this region/account."
    }

    precondition {
      condition     = (var.existing_vpc_id == null) == (var.existing_subnet_id_primary == null) && (var.existing_vpc_id == null) == (var.existing_subnet_id_backup == null)
      error_message = "existing_vpc_id, existing_subnet_id_primary, and existing_subnet_id_backup must all be set or all be null."
    }
  }

  tags = {
    Name = "${var.name_prefix}-n3uron-primary"
    Role = "primary"
  }
}

resource "aws_instance" "backup" {
  ami                    = local.selected_ami_id
  instance_type          = var.instance_type
  subnet_id              = local.subnet_id_backup
  vpc_security_group_ids = [aws_security_group.n3uron_sg.id, aws_security_group.backup_client.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.n3uron_ec2.name

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size_gb
    encrypted   = var.root_volume_encrypted
  }

  lifecycle {
    precondition {
      condition     = local.selected_ami_id != null
      error_message = "Set ami_id or ensure the hardcoded Marketplace product code resolves an AMI in this region/account."
    }
  }

  tags = {
    Name = "${var.name_prefix}-n3uron-backup"
    Role = "backup"
  }
}

resource "aws_eip" "primary" {
  domain = "vpc"
  tags   = { Name = "${var.name_prefix}-eip-primary" }
}

resource "aws_eip_association" "primary" {
  instance_id   = aws_instance.primary.id
  allocation_id = aws_eip.primary.id
}

resource "aws_eip" "backup" {
  domain = "vpc"
  tags   = { Name = "${var.name_prefix}-eip-backup" }
}

resource "aws_eip_association" "backup" {
  instance_id   = aws_instance.backup.id
  allocation_id = aws_eip.backup.id
}
