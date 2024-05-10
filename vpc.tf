resource "aws_vpc" "main" {
  cidr_block = var.CIDR
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.SUBCIDR
  map_public_ip_on_launch = true
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
resource "aws_vpc_security_group_egress_rule" "ctfd-egress" {
  security_group_id = aws_security_group.ctfd-secgroup.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  from_port = 0
  to_port = 0
}

resource "aws_alb_target_group" "ctfd" {
  name = "ctfd-TargetGroup"
  port = 8000
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_alb" "alb" {
  name = "ctfd-alb"
  security_groups = [aws_security_group.ctfd-secgroup.id]
  subnets = [aws_subnet.main.id]
}
resource "aws_alb_listener" "cftd-alb-listener" {
  load_balancer_arn = aws_alb.alb.arn
  default_action {
    type = "forward"
     target_group_arn = aws_alb_target_group.ctfd.arn
  }
  
}
