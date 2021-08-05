
resource "aws_cloudwatch_metric_alarm" "Disk_Space_kafkaInstance" {
  alarm_name                = "Disk_Space_kafkaInstance"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "DiskSpaceUtilization"
  namespace                 = "CWAgent"



  dimensions = {
      InstanceId    = "i-01fdc617e6e5016e1" #Please do a data source and remove the hardcode
      # InstanceId  = data.aws_instance.kafka_instance.
      path          = "/"
      device        = "your-device"
      fstype        = "xfs"

  }

  period                    = "10"
  statistic                = "Average"
  threshold                 = "50" 
  alarm_description         = "Disk usage for / is high"
  insufficient_data_actions = []
  actions_enabled           = true
  alarm_actions             = ["arn:aws:cloudwatch:ap-southeast-1:483506802077:alarm:Kafka Disk Space Metrics"] #variablize it 
  ok_actions                = ["arn:aws:cloudwatch:ap-southeast-1:483506802077:alarm:Kafka Disk Space Metrics"]
}
