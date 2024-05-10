resource "aws_ecs_cluster" "ctfd-cluser" {
  name = var.ECS_CLUSTER
}

resource "aws_ecs_cluster_capacity_providers" "cap-providers" {
  cluster_name       = aws_ecs_cluster.ctfd-cluser.name
  capacity_providers = ["FARGATE"]

}

resource "aws_ecs_task_definition" "ctfd-task" {
  family                = var.SERVICE_NAME
  requires_compatibilities = ["FARGATE"]
  container_definitions = file("./service.json")
  network_mode          = "awsvpc"
  cpu                   = 1024
  memory                = 3072

}

resource "aws_ecs_service" "ctfd-svc" {
  name            = "secret_Service"
  cluster         = aws_ecs_cluster.ctfd-cluser.id
  task_definition = aws_ecs_task_definition.ctfd-task.arn
  desired_count   = 1
  network_configuration {
    subnets          = [aws_subnet.main.id]
    security_groups  = [aws_security_group.ctfd-secgroup.id]
  }
  lifecycle {
    create_before_destroy = true
  }

}

