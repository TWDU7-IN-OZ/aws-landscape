resource "aws_ebs_volume" "kafka_ebs" {
  availability_zone = "${element(var.availability_zones, count.index)}"
  size = 100
}

resource "aws_instance" "kafka" {
  ami                    = "${data.aws_ami.training_kafka.image_id}"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.kafka.id}"]
  subnet_id              = "${var.subnet_id}"
  key_name               = "${var.ec2_key_pair}"
  iam_instance_profile   = "${aws_iam_instance_profile.kafka.name}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "kafka-${var.deployment_identifier}"
    )
  )}"
}

resource "aws_volume_attachment" "kafka_instance_ebs_attachment" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.kafka_ebs.id}"
  instance_id = "${aws_instance.kafka.id}"
}
