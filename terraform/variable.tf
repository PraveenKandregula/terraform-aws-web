variable "aws_region" {}
#variable "vpc_id" {}
variable "project_name" {}
#variable "cidr_range" {}
variable "ami" {}
variable "instances_count" {}
variable "key_name" {}
variable "availability_zones" { 
  type = "list" 
}
