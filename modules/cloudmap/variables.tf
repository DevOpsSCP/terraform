variable "project_name" {
  type        = string
  default     = "juice_shop"
  description = "Project name"
}

###########################################################################################
######################################### module ##########################################
###########################################################################################

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}
