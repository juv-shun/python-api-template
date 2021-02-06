resource "aws_ecr_repository" "ecr" {
  name = var.server_name
}

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle" {
  repository = aws_ecr_repository.ecr.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Delete old images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecs_cluster" "cluster" {
  name = var.server_name
}

resource "aws_ecs_service" "service" {
  name                              = var.server_name
  cluster                           = aws_ecs_cluster.cluster.arn
  task_definition                   = aws_ecs_task_definition.task_def_dummy.family
  desired_count                     = 0
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0"
  health_check_grace_period_seconds = 30

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    container_name   = var.lb_target_container
    container_port   = 80
    target_group_arn = aws_alb_target_group.target_group_blue.arn
  }

  network_configuration {
    security_groups = [var.default_security_group]
    subnets = [
      var.subnet["az1"],
      var.subnet["az2"]
    ]
  }

  lifecycle {
    ignore_changes = [desired_count, load_balancer, task_definition]
  }
}

resource "aws_ecs_task_definition" "task_def_dummy" {
  family                   = var.server_name
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task_exe_role.arn
  network_mode             = "awsvpc"
  container_definitions    = jsonencode(local.task_def)
  tags                     = {}
  requires_compatibilities = ["FARGATE"]

  lifecycle {
    ignore_changes = [cpu, memory, execution_role_arn, network_mode, tags, container_definitions, tags, requires_compatibilities]
  }
}

locals {
  task_def = [
    {
      "portMappings" : [
        {
          "hostPort" : 80,
          "protocol" : "tcp",
          "containerPort" : 80
        }
      ],
      "image" : "dummy",
      "essential" : true,
      "name" : var.lb_target_container,
    }
  ]
}

resource "aws_iam_role" "task_exe_role" {
  name               = "${var.server_name}-task-exe-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "task_exe_role_attachment" {
  role       = aws_iam_role.task_exe_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_role" {
  name               = "${var.server_name}-task-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_policy.json
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/${var.server_name}"
  retention_in_days = 30
}
