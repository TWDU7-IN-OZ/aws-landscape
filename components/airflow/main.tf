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

  vpc_id            = "${module.vpc.vpc_id}"

  security_group_id = "${aws_security_group.airflow-security-group.id}"
  subnet_ids        = [ "${module.vpc.public_subnets[0]}", "${module.vpc.public_subnets[1]}" ]

}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "airflow-test-vpc"
  cidr = "10.10.0.0/16"

  azs             = ["eu-west-1a",     "eu-west-1b",     "eu-west-1c"    ]
  private_subnets = ["10.10.1.0/24",   "10.10.2.0/24",   "10.10.3.0/24"  ]
  public_subnets  = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]

  enable_dns_hostnames = true
}