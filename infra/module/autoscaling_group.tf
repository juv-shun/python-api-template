resource "aws_autoscaling_group" "autoscaling-group" {
  name             = var.server_name
  max_size         = var.autoscaling_config["max_instance_size"]
  min_size         = var.autoscaling_config["min_instance_size"]
  desired_capacity = var.autoscaling_config["desired_capacity"]
  vpc_zone_identifier = [
    var.subnet.az1,
    var.subnet.az2,
  ]
  launch_configuration = aws_launch_configuration.launch_configuration.name
  health_check_type    = "ELB"
  tag {
    key                 = "Name"
    value               = var.server_name
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "launch_configuration" {
  name                 = var.server_name
  image_id             = var.ec2_config["image_id"]
  instance_type        = var.ec2_config["instance_type"]
  iam_instance_profile = aws_iam_instance_profile.instance_profile.id

  root_block_device {
    volume_type           = "standard"
    volume_size           = 100
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  security_groups = [
    var.default_security_group,
    aws_security_group.http_sg.id
  ]
  associate_public_ip_address = "true"
  key_name                    = var.key_pair
  user_data                   = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.cluster.name} >> /etc/ecs/ecs.config
EOF
}
