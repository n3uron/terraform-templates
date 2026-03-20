resource "aws_iam_role" "n3uron_ec2" {
  name_prefix = "${var.name_prefix}-n3uron-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Name = "${var.name_prefix}-n3uron-role" }
}

resource "aws_iam_role_policy_attachment" "n3uron_ec2_ssm" {
  role       = aws_iam_role.n3uron_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "n3uron_ec2" {
  name_prefix = "${var.name_prefix}-n3uron-"
  role        = aws_iam_role.n3uron_ec2.name

  tags = { Name = "${var.name_prefix}-n3uron-profile" }
}
