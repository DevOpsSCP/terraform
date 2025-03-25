variable "project_name" {
  type        = string
  default     = "juice-shop"
  description = "Project name"
}

###########################################################################################
######################################### module ##########################################
###########################################################################################

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnet_id_01" {
  type        = string
  description = "Public Subnet ID-01"
}

variable "public_subnet_id_02" {
  type        = string
  description = "Public Subnet ID-02"
}

variable "alb_security_group_id" {
  type        = string
  description = "ALB Security group ID"
}
