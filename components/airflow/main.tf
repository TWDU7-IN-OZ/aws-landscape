data "terraform_remote_state" "trainingairflow" {
  backend = "s3"
  config {
    key    = "airflow.tfstate"
    bucket = "tw-dataeng-${var.cohort}-tfstate"
    region = "${var.aws_region}"
  }
}


module "airflow" {
  source = "../../modules/airflow"
}
