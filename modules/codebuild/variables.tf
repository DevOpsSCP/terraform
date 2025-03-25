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

###########################################################################################
######################################## Codebuild ########################################
###########################################################################################

variable "git_repo_url" {
  type        = string
  default     = "https://github.com/DevOpsSCP/juice-shop"
  description = "Github repository URL"
}

###########################################################################################
######################################### module ##########################################
###########################################################################################

variable "sast_result_s3_name" {
  type        = string
  description = "SAST S3 bucket Name"
}

variable "codebuild_s3_name" {
  type        = string
  description = "codebuild_s3_name"
}

variable "ecr_repository_url" {
  type        = string
  description = "ECR Repository URL"
}

variable "snyk_token_arn" {
  type        = string
  description = "Snyk Token ARN"
}

variable "semgrep_token_arn" {
  type        = string
  description = "Semgrep Token ARN"
}
