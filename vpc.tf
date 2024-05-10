resource "aws_vpc" "main" {
  cidr_block = var.CIDR
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.SUBCIDR
}

resource "aws_security_group" "ctfd-secgroup" {
  name   = var.SECGROUP
  vpc_id = aws_vpc.main.id
}
resource "aws_vpc_security_group_ingress_rule" "ctfd-ingress" {
  security_group_id = aws_security_group.ctfd-secgroup.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.CTFD_PORT
  ip_protocol       = "tcp"
  to_port           = var.CTFD_PORT
}
resource "aws_vpc_security_group_egress_rule" "ctfd-ingress" {
  security_group_id = aws_security_group.ctfd-secgroup.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
}
