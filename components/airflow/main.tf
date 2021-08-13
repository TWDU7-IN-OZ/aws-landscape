provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 2.0"
}

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
  version           = "0.1.4"

  ami               = "ami-6e28b517" # CentOS 7 community image for eu-west-1
  key               = "airflow-test"
  db_password       = "thisistheairflowdbpassword"
  fernet_key        = "8hEdQizWjFGANL-MfypCwijKR66tb3uYNdJsrZRioaI="

  vpc_id            = "vpc-031ca3def345cce88"

  security_group_id = "sgr-0f8df69cc112eb46c"
  # subnet_ids        = [ "${module.vpc.public_subnets[0]}", "${module.vpc.public_subnets[1]}" ]
  subnet_ids = ["subnet-0067b49e65d5c24e8", "subnet-0b52b420abc514df3"]

}

# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"

#   name = "airflow-test-vpc"
#   cidr = "10.10.0.0/16"

#   azs             = ["eu-west-1a",     "eu-west-1b",     "eu-west-1c"    ]
#   private_subnets = ["10.10.1.0/24",   "10.10.2.0/24",   "10.10.3.0/24"  ]
#   public_subnets  = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]

#   enable_dns_hostnames = true
# }