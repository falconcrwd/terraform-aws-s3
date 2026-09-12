# Look up the default VPC in the target region
data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "test_nsg" {
  name        = var.sg_name
  description = "Test security group managed by Terraform"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = var.sg_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Ingress rules (modern per-rule resources; avoids in-line rule drift)
resource "aws_vpc_security_group_ingress_rule" "https" {
  for_each = toset(var.allowed_ingress_cidrs)

  security_group_id = aws_security_group.test_nsg.id
  description       = "HTTPS from ${each.value}"
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# Allow all outbound IPv4
resource "aws_vpc_security_group_egress_rule" "all_ipv4" {
  security_group_id = aws_security_group.test_nsg.id
  description       = "Allow all outbound IPv4"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

 resource "aws_instance" "bad" {
    ami           = "ami-1234"
    instance_type = "t9.mega"   # ← not a real instance type
  }
