data "terraform_remote_state" "training_kafka" {
  backend = "s3"
  config {
    key    = "training_kafka.tfstate"
    bucket = "tw-dataeng-${var.cohort}-tfstate"
    region = var.aws_region
  }
}

resource "aws_cloudwatch_metric_alarm" "Disk_Space_kafkaInstanceDisk" {
  alarm_name = "Kafka EBS Consumption over Threshold"
  AlarmDescription = "Kafka EBS mount has utilised more space then the threshold"
  alarm_actions = [
    "arn:aws:sns:ap-southeast-1:483506802077:twdu7_CloudWatch_Alarms_Topic"]
  ok_actions = []
  actions_enabled = true
  insufficient_data_actions = []
  metric_name = "disk_used_percent"
  namespace = "CWAgent"
  statistic = "Average"

  dimensions = {
    path = "/data"
    InstanceId = data.terraform_remote_state.training_kafka.kafka_instance_id
    device = "xvdh"
    fstype = "xfs"

  }

  period = 300
  evaluation_periods = 1
  datapoints_to_alarm = 1
  threshold = "75"
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data = "missing"
}