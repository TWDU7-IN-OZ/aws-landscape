resource "aws_s3_bucket" "airflow_bucket" {
  bucket = "airflow-dag-bucket"
  acl    = "private"

  tags = {
    Name        = "Airflow DAGs"
    Environment = "Dev"
  }
}

resource "aws_iam_role" "airflow_role" {
  name = "airflow_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_mwaa_environment" "mwaa" {
  dag_s3_path        = "dags/"
  execution_role_arn = aws_iam_role.airflow_role.arn
  name               = "example"

  network_configuration {
    security_group_ids = [aws_security_group.airflow_security_group.id]
    subnet_ids         = aws_subnet.airflow_subnets[*].id
  }

  source_bucket_arn = aws_s3_bucket.airflow_bucket.arn
}

data "aws_subnet" "airflow_subnets" {
  id = [subnet-0067b49e65d5c24e8, subnet-0b52b420abc514df3]
}

data "aws_security_group" "airflow_security_group" {
  id = "sg-0d303d0123f83eedf"
}
