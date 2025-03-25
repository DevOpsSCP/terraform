variable "project_name" {
  type        = string
  default     = "juice_shop"
  description = "Project name"
}

variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}
