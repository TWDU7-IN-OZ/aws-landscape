variable "cohort" {
  description = "Training cohort, eg: london-summer-2018"
}

variable "aws_region" {
  description = "Region in which to build resources."
}

variable "kafka" {
  type = map(string)
  default = {
    instance_type = "t2.medium"
  }
}
