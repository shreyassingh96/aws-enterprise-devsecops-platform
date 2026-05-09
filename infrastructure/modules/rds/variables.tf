variable "project_name" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "db_subnet_group_name" { type = string }
variable "eks_cluster_security_group_id" { type = string }
variable "instance_class" { type = string }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
