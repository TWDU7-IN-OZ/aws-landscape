
resource "aws_cloudwatch_metric_alarm" "Disk_Space_kafkaInstance" {
  alarm_name                = "Disk_Utilization_Kafka"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "DiskSpaceUtilization"
  namespace                 = "AWS/EBS"



  dimensions = {
      VolumeId    = "vol-0d8138e6259608284" #Please do a data source and remove the hardcode
      # InstanceId  = data.aws_instance.kafka_instance.
      MountPath          = "/data"
      InstanceType = "m4.large"
      Filesystem        = "/dev/xvdh"
  }

  period                    = "300"
  statistic                = "Average"
  threshold                 = "50"
  alarm_description         = "Disk usage for /dev/xvdh is high"
  insufficient_data_actions = []
  actions_enabled           = true
  alarm_actions             = ["arn:aws:cloudwatch:ap-southeast-1:483506802077:alarm:Kafka Disk Space Metrics"] #variablize it
  ok_actions                = ["arn:aws:cloudwatch:ap-southeast-1:483506802077:alarm:Kafka Disk Space Metrics"]
}


resource "aws_cloudwatch_metric_alarm" "Disk_Space_kafkaInstance" {
  alarm_name          = "Disk_Utilization_KafkaDisk"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DiskSpaceUtilization"
  namespace           = "System/Linux"



  dimensions = {
     InstanceId  = "i-01fdc617e6e5016e1" #Please do a data source and remove the hardcode
    # InstanceId  = data.aws_instance.kafka_instance.
    MountPath    = "/data"
    InstanceType = "m4.large"
    Filesystem   = "/dev/xvdh"
  }

  period                    = "300"
  statistic                 = "Average"
  threshold                 = "70"
  alarm_description         = "Disk usage for /dev/xvdh is high"
  insufficient_data_actions = []
  actions_enabled           = true
  alarm_actions             = ["arn:aws:cloudwatch:ap-southeast-1:483506802077:alarm:Kafka Disk Space Metrics"] #variablize it
  ok_actions                = ["arn:aws:cloudwatch:ap-southeast-1:483506802077:alarm:Kafka Disk Space Metrics"]
}