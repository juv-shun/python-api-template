resource "aws_ecr_repository" "ecr" {
  name = var.system_name
}

resource "aws_ecs_cluster" "cluster" {
  name = var.system_name
}
