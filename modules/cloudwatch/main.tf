data "aws_instance" "kafka_instance" {
  filter {
    name = "name"
    values = [
      "kafka-data-eng-twdu7-in-oz"]
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
    InstanceId = data.aws_instance.kafka_instance.id
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