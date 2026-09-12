# Look up the default VPC in the target region
data "aws_vpc" "default" {
  default = true
}

# Common tags applied to every taggable resource. Kept here (not in provider
# default_tags) so Checkov's static parser can see them on each resource and
# the CKV_LOCAL_001 policy (environment=demo) can be enforced.
locals {
  common_tags = {
    environment = "demo"
  }
}

resource "aws_security_group" "test_nsg" {
  name        = var.sg_name
  description = "Test security group managed by Terraform"
  vpc_id      = data.aws_vpc.default.id

  tags = merge(local.common_tags, {
    Name = var.sg_name
  })

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

  tags = local.common_tags
}

# Allow all outbound IPv4
resource "aws_vpc_security_group_egress_rule" "all_ipv4" {
  security_group_id = aws_security_group.test_nsg.id
  description       = "Allow all outbound IPv4"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = local.common_tags
}
