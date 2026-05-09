variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "kms_key_id" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_host" {
  type = string
}

variable "db_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
