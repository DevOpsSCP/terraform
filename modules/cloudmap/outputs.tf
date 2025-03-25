output "cloudmap_namespace_id" { 
  value       = aws_service_discovery_private_dns_namespace.cloudmap_namespace.id
  description = "Cloud Map Namespace ID"
}

output "cloudmap_namespace_arn" { 
  value       = aws_service_discovery_private_dns_namespace.cloudmap_namespace.arn
  description = "Cloud Map Namespace ARN"
}

output "cloudmap_namespace_name" { 
  value       = aws_service_discovery_private_dns_namespace.cloudmap_namespace.name
  description = "Cloud Map Namespace name"
}

output "cloudmap_service_id" { 
  value       = aws_service_discovery_service.cloudmap_service.id
  description = "Cloud Map Service ID"
}

output "cloudmap_service_arn" { 
  value       = aws_service_discovery_service.cloudmap_service.arn
  description = "Cloud Map Service ARN"
}

output "cloudmap_service_name" { 
  value       = aws_service_discovery_service.cloudmap_service.name
  description = "Cloud Map Service name"
}
