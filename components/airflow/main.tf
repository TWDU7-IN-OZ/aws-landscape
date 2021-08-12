data "terraform_remote_state" "trainingairflow" {
  backend = "s3"
  config {
    key    = "airflow.tfstate"
    bucket = "tw-dataeng-${var.cohort}-tfstate"
    region = "${var.aws_region}"
  }
}



module "airflow" {
    source = "datarootsio/ecs-airflow/aws"

    resource_prefix = "TWdutest"
    resource_suffix = "env"

    vpc_id             = "vpc-123456"
    public_subnet_ids  = ["subnet-456789", "subnet-098765"]

    airflow_executor = "Sequential"
    # airflow_variables = {
    #   AIRFLOW__WEBSERVER__NAVBAR_COLOR : "#e27d60"
    # }

    use_https = false
}

# output "airflow_alb_dns" {
#   value = module.airflow.airflow_alb_dns
# }