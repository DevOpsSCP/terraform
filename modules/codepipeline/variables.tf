variable "project_name" {
  type        = string
  default     = "juice_shop"
  description = "Project name"
}

variable "git_repo_name" {
  type        = string
  default     = "juice-shop"
  description = "git_repo_name"
}

variable "git_owner" {
  type        = string
  default     = "DevOpsSCP"
  description = "git_owner"
}

variable "github_oauth_token" {
  type        = string
  default     = ""
  description = "github_oauth_token"
}

###########################################################################################
######################################### module ##########################################
###########################################################################################

variable "codebuild_s3_name" {
  type        = string
  description = "codebuild_s3_name"
}

variable "codebuild_name" {
  type        = string
  description = "codebuild_name"
}

variable "ecs_cluster_name" {
  type        = string
  description = "ecs_cluster_name"
}

variable "ecs_service_name" {
  type        = string
  description = "ecs_service_name"
}

variable "lambda_function_name" {
  type        = string
  description = "lambda_function_name"
}

variable "ecs_task_execution_role_arn" {
  type        = string
  description = "ecs_task_execution_role_arn"
}
