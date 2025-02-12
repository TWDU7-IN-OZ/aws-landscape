terraform {
  backend "s3" {}
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 2.0"
}

data "terraform_remote_state" "monitoring" {
  backend = "s3"
  config {
    key    = "monitoring.tfstate"
    bucket = "tw-dataeng-${var.cohort}-tfstate"
    region = "${var.aws_region}"
  }
}



module "cloudwatch" {
  source = "../../modules/cloudwatch"
  cohort = "${var.cohort}"
  aws_region = "${var.aws_region}"
}