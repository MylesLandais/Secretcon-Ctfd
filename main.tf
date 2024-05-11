resource "aws_ecs_cluster" "ctfd-cluser" {
  name = var.ECS_CLUSTER
}
resource "aws_ecs_task_definition" "ctfd-task" {
  family                   = var.SERVICE_NAME
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./service.json")
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_task_execution.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
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
  launch_type = "FARGATE"
  desired_count   = 1
  load_balancer {
    target_group_arn = aws_alb_target_group.ctfd.arn
    container_name   = "ctfd"
    container_port   = 8000
  }
  network_configuration {
    subnets         = aws_subnet.main.*.id
    security_groups = [aws_security_group.ctfd-secgroup.id]
    assign_public_ip = true
  }
}

module "ecs-service-autoscaling" {
  source                    = "cn-terraform/ecs-service-autoscaling/aws"
  version                   = "1.0.3"
  ecs_cluster_name          = aws_ecs_cluster.ctfd-cluser.name
  ecs_service_name          = aws_ecs_service.ctfd-svc.name
  name_prefix               = "ctfd"
  scale_target_min_capacity = 1
  max_cpu_threshold         = 2048
}
