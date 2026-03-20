resource "aws_instance" "n3uron_ec2" {
  ami                    = local.selected_ami_id
  instance_type          = var.instance_type
  subnet_id              = local.subnet_id
  vpc_security_group_ids = [aws_security_group.n3uron_sg.id]
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
    # Uncomment in production to prevent accidental destruction.
    # prevent_destroy = true

    precondition {
      condition     = local.selected_ami_id != null
      error_message = "Set ami_id or ensure the hardcoded Marketplace product code resolves an AMI in this region/account."
    }

    precondition {
      condition     = (var.existing_vpc_id == null) == (var.existing_subnet_id == null)
      error_message = "existing_vpc_id and existing_subnet_id must both be set or both be null."
    }
  }

  tags = {
    Name = "${var.name_prefix}-n3uron"
  }
}

resource "aws_eip" "n3uron_eip" {
  domain = "vpc"

  tags = { Name = "${var.name_prefix}-eip" }
}

resource "aws_eip_association" "n3uron_eip_assoc" {
  instance_id   = aws_instance.n3uron_ec2.id
  allocation_id = aws_eip.n3uron_eip.id
}
