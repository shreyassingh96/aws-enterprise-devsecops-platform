variable "domain_name" {
  description = "The root domain name"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
