output "codebuild_role_name" { 
  value       = aws_iam_role.codebuild_role.name
  description = "Codebuild role name"
}

output "codebuild_role_arn" { 
  value       = aws_iam_role.codebuild_role.arn
  description = "Codebuild role ARN"
}

output "codebuild_name" { 
  value       = aws_codebuild_project.main_codebuild.name
  description = "Codebuild name"
}

output "codebuild_arn" { 
  value       = aws_codebuild_project.main_codebuild.arn
  description = "Codebuild ARN"
}

output "git_repo_url" {
  value = var.git_repo_url
}
