resource "aws_cloudwatch_metric_alarm" "Disk_Space_kafkaInstanceDisk"{
    alarm_name = "KafkUtilisationAlarm"
    alarm_actions = ["arn:aws:sns:ap-southeast-1:483506802077:twdu7_CloudWatch_Alarms_Topic"]
    ok_actions = []
    actions_enabled = true
    insufficient_data_actions = []
    metric_name = "DiskSpaceUtilization"
    namespace = "System/Linux"
    statistic = "Average"

    dimensions = {
        MountPath = "/"
        InstanceId = "i-01fdc617e6e5016e1"
        Filesystem = "/dev/xvda1"
    }

    period = 300
    evaluation_periods = 1
    datapoints_to_alarm = 1
    threshold = "70"
    comparison_operator = "GreaterThanThreshold"
    treat_missing_data = "missing"
}