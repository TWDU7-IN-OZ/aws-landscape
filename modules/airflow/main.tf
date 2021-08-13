# resource "aws_s3_bucket" "airflow_bucket" {
#   bucket = "airflow-dag-bucket"
#   acl    = "private"

#   tags = {
#     Name        = "Airflow DAGs"
#     Environment = "Dev"
#   }
# }

# resource "aws_iam_role" "airflow_role" {
#   name = "airflow_role"
#   assume_role_policy = "${data.aws_iam_policy_document.airflow_assume_role.json}"

# }

# resource "aws_mwaa_environment" "mwaa" {
#   dag_s3_path        = "dags/"
#   execution_role_arn = "${aws_iam_role.airflow_role.arn}"
#   name               = "example"

#   network_configuration {
#     security_group_ids = "${aws_security_group.airflow_security_group.id}"
#      subnet_ids         = "${aws_subnet.airflow_subnets.*.id}"
#     # subnet_ids         = ["${aws_subnet.airflow_subnet1.id}", "${aws_subnet.airflow_subnet2.id}"]
#   }

#   source_bucket_arn = "${aws_s3_bucket.airflow_bucket.arn}"
# }
# data "aws_subnet" "airflow_subnets" {
#   id = ([subnet-0067b49e65d5c24e8, subnet-0b52b420abc514df3])
# }


# data "aws_subnet" "airflow_subnet1" {
#   id = "subnet-0067b49e65d5c24e8"
# }

# data "aws_subnet" "airflow_subnet2" {
#   id = "subnet-0b52b420abc514df3"
# }

# data "aws_security_group" "airflow_security_group" {
#   id = "sg-0d303d0123f83eedf"
# }

# data "aws_iam_policy_document" "airflow_assume_role" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }
#   }
# }



data "template_file" "airflow_user_data" {
  template = "${file("${path.module}/files/cloud-init.sh")}"
}

data "template_file" "airflow_config" {
  template = "${file("${path.module}/files/airflow.cfg")}"
  vars {
    fernet_key = "${var.fernet_key}"
    db_url     = "${aws_db_instance.airflow-database.address}"
    db_pass    = "${aws_db_instance.airflow-database.password}"
  }
}


resource "aws_instance" "airflow_instance" {
  key_name                    = "${var.key}"
  associate_public_ip_address = true
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${var.subnet_ids[0]}"
  vpc_security_group_ids      = [ "${var.security_group_id}", ]

  root_block_device {
    volume_size = 32
  }

  tags {
    Name = "airflow"
  }

  provisioner "file" {
    content     = "${data.template_file.airflow_config.rendered}"
    destination = "/var/tmp/airflow.cfg"

    connection {
      user     = "centos"
    }
  }

  user_data  = "${data.template_file.airflow_user_data.rendered}"
}


resource "aws_db_instance" "airflow-database" {
  identifier                = "airflow-database"
  allocated_storage         = 20
  engine                    = "postgres"
  engine_version            = "9.6.6"
  instance_class            = "db.t2.small"
  name                      = "airflow"
  username                  = "airflow"
  password                  = "${var.db_password}"
  storage_type              = "gp2"
  backup_retention_period   = 14
  multi_az                  = false
  publicly_accessible       = false
  apply_immediately         = true
  db_subnet_group_name      = "${aws_db_subnet_group.airflow_subnetgroup.name}"
  final_snapshot_identifier = "airflow-database-final-snapshot-1"
  skip_final_snapshot       = false
  vpc_security_group_ids    = [ "${aws_security_group.allow_airflow_database.id}"]
  port                      = "5432"
}

resource "aws_db_subnet_group" "airflow_subnetgroup" {
  name        = "airflow-database-subnetgroup"
  description = "airflow database subnet group"
  subnet_ids  = [ "${var.subnet_ids}" ]
}

resource "aws_security_group" "allow_airflow_database" {
  name        = "allow_airflow_database"
  description = "Controlling traffic to and from airflows rds instance."
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_airflow_database" {
  security_group_id = "${aws_security_group.allow_airflow_database.id}"
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"

  cidr_blocks = [
    "${aws_instance.airflow_instance.private_ip}/32"
  ]
}