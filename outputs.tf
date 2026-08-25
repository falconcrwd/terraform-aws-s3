output "security_group_id" {
  description = "ID of the created security group"
  value       = aws_security_group.test_nsg.id
}

output "security_group_arn" {
  description = "ARN of the created security group"
  value       = aws_security_group.test_nsg.arn
}

output "default_vpc_id" {
  description = "ID of the default VPC"
  value       = data.aws_vpc.default.id
}
