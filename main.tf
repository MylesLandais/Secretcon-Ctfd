resource "aws_ecs_cluster" "ctfd-cluser" {
  name = var.ECS_CLUSTER
}

resource "aws_ecs_cluster_capacity_providers" "cap-providers" {
  cluster_name       = aws_ecs_cluster.ctfd-cluser.name
  capacity_providers = ["FARGATE_SPOT"]

}

resource "aws_ecs_task_definition" "ctfd-task" {
  family                = var.SERVICE_NAME
  container_definitions = file("./service.json")
  network_mode          = "awsvpc"
  cpu                   = 1024
  memory                = 3072

}

resource "aws_ecs_service" "ctfd-svc" {
  name            = var.SERVICE_NAME
  cluster         = aws_ecs_cluster.ctfd-cluser.id
  task_definition = aws_ecs_task_definition.ctfd-task.arn
  desired_count   = 1
  network_configuration {
    subnets          = aws_subnet.main.cidr_block
    security_groups  = aws_security_group.ctfd-secgroup.name
    assign_public_ip = true
  }

}
resource "aws_ecs_task_set" "ctfd-task-set" {
  service         = aws_ecs_service.ctfd-svc.id
  cluster         = aws_ecs_cluster.ctfd-cluser.id
  task_definition = aws_ecs_task_definition.ctfd-task.arn

}
