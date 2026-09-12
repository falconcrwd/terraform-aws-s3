variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "sg_name" {
  description = "Name of the security group"
  type        = string
  default     = "test1-nsg"
}

variable "allowed_ingress_cidrs" {
  description = "CIDR blocks allowed inbound on HTTPS"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}
