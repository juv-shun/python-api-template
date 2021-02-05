resource "aws_ecr_repository" "ecr" {
  name = var.server_name
}

resource "aws_ecs_cluster" "cluster" {
  name = var.server_name
}
