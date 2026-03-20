data "aws_region" "current" {}

resource "aws_cloudwatch_metric_alarm" "n3uron_status_check" {
  alarm_name          = "${var.name_prefix}-n3uron-status-check-failed-system"
  alarm_description   = "Auto recovery when AWS hardware fails (System Status Check)."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Minimum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.n3uron_ec2.id
  }

  alarm_actions = ["arn:aws:automate:${data.aws_region.current.name}:ec2:recover"]

  tags = { Name = "${var.name_prefix}-status-check-alarm" }
}

resource "aws_cloudwatch_metric_alarm" "n3uron_cpu_high" {
  alarm_name          = "${var.name_prefix}-n3uron-cpu-high"
  alarm_description   = "Alarm when EC2 CPU is above 70% during the last 5 minutes."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.n3uron_ec2.id
  }

  tags = { Name = "${var.name_prefix}-cpu-alarm" }
}
