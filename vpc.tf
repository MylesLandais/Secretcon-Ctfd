data "aws_availability_zones" "available" {}
resource "aws_vpc" "main" {
  cidr_block = var.CIDR
}

resource "aws_subnet" "main" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.SUBCIDR, 4, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
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

}

resource "aws_alb_target_group" "ctfd" {
  name        = "ctfd-TargetGroup"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_alb" "alb" {
  name            = "ctfd-alb"
  security_groups = [aws_security_group.ctfd-secgroup.id]
  subnets         = aws_subnet.main.*.id
}
resource "aws_alb_listener" "cftd-alb-listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 8000
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ctfd.arn
  }

}
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.main.id

}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
}

resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_main_route_table_association" "public_main" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.public.id
}

