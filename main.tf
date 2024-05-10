resource "aws_ecs_cluster" "ctfd-cluser" {
  name = var.ECS_CLUSTER
}

resource "aws_ecs_cluster_capacity_providers" "cap-providers" {
  cluster_name       = aws_ecs_cluster.ctfd-cluser.name
  capacity_providers = ["FARGATE"]

}

resource "aws_ecs_task_definition" "ctfd-task" {
  family                   = var.SERVICE_NAME
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./service.json")
  network_mode             = "awsvpc"
  task_role_arn            = "arn:aws:iam::975050366977:role/ecsTaskExecutionRole"
  cpu                      = 1024
  memory                   = 3072
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

}

resource "aws_ecs_service" "ctfd-svc" {
  name            = "secretctfd"
  cluster         = aws_ecs_cluster.ctfd-cluser.id
  task_definition = aws_ecs_task_definition.ctfd-task.arn
  desired_count   = 1
  load_balancer {
    target_group_arn = aws_alb_target_group.ctfd.arn
    container_name   = "ctfd"
    container_port   = 8000
  }
  network_configuration {
    subnets         = [aws_subnet.main.id]
    security_groups = [aws_security_group.ctfd-secgroup.id]
  }
}

