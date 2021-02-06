resource "aws_db_instance" "db" {
  identifier              = var.db_name
  allocated_storage       = var.rds_settings["allocated_storage"]
  engine                  = "mysql"
  engine_version          = "8.0.17"
  instance_class          = var.rds_settings["instance_class"]
  multi_az                = var.rds_settings["multi_az"]
  username                = var.rds_settings["database_username"]
  password                = var.rds_settings["database_password"]
  port                    = "3306"
  db_subnet_group_name    = aws_db_subnet_group.subnet_group.id
  vpc_security_group_ids  = [var.security_group_id]
  skip_final_snapshot     = true
  storage_type            = "gp2"
  maintenance_window      = "Sun:15:00-Sun:16:00"
  backup_retention_period = 0
  backup_window           = "14:00-15:00"
  name                    = var.rds_settings["db_name"]
  parameter_group_name    = aws_db_parameter_group.parameter_group.id
}

resource "aws_db_subnet_group" "subnet_group" {
  name = var.db_name

  subnet_ids = [
    var.subnet["az1"],
    var.subnet["az2"],
  ]
}

resource "aws_db_parameter_group" "parameter_group" {
  name   = var.db_name
  family = "mysql8.0"

  parameter {
    name         = "time_zone"
    value        = "Asia/Tokyo"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "character_set_client"
    value        = "utf8mb4"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "character_set_connection"
    value        = "utf8mb4"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "character_set_results"
    value        = "utf8mb4"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "skip-character-set-client-handshake"
    value        = "1"
    apply_method = "pending-reboot"
  }
}
