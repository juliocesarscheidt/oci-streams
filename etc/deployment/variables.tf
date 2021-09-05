variable "region" {
  type    = string
  default = "sa-saopaulo-1"
}

variable "tenancy_ocid" {
  type = string
}

variable "user_ocid" {
  type = string
}

variable "user_key_fingerprint" {
  type = string
}

variable "stream_prefix" {
  type = string
  default = "kafka"
}

variable "stream_user_name" {
  type = string
  default = "stream_user"
}

variable "stream_partitions" {
  type = number
  default = 1
}

variable "stream_retention_in_hours" {
  type = number
  default = 24
}

variable "tags" {
  type    = map
  default = { "ENVIRONMENT" = "DEV", "MANAGED_BY" = "Terraform" }
}
