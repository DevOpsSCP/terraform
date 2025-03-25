output "alb_id" { 
  value       = aws_lb.Application_Load_Balancer.id
  description = "ALB ID"
}

output "alb_dns_name" { 
  value       = aws_lb.Application_Load_Balancer.dns_name
  description = "ALB DNS Name"
}

output "alb_arn" { 
  value       = aws_lb.Application_Load_Balancer.arn
  description = "ALB ARN"
}

output "alb_target_group_id" { 
  value       = aws_lb_target_group.alb_target_group.id
  description = "ALB Target group ID"
}

output "alb_target_group_name" { 
  value       = aws_lb_target_group.alb_target_group.name
  description = "ALB Target group name"
}

output "alb_target_group_arn" { 
  value       = aws_lb_target_group.alb_target_group.arn
  description = "ALB Target group ARN"
}

output "alb_listener_id" { 
  value       = aws_lb_listener.alb_listener.id
  description = "ALB Listener ID"
}

output "alb_listener_arn" { 
  value       = aws_lb_listener.alb_listener.arn
  description = "ALB Listener ARN"
}
