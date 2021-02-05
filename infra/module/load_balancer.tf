# resource "aws_alb" "load_balancer" {
#   name = var.server_name
#   security_groups = [
#     var.default_security_group,
#     aws_security_group.http_sg.id
#   ]
#   subnets = [
#     var.subnet.az1,
#     var.subnet.az2,
#   ]

#   access_logs {
#     bucket  = var.access_logs_bucket
#     prefix  = var.server_name
#     enabled = true
#   }
# }

resource "aws_alb_target_group" "target_group" {
  name                 = var.server_name
  port                 = "80"
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = 90

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "4"
    interval            = "30"
    matcher             = "200"
    path                = "/heartbeat"
    protocol            = "HTTP"
    timeout             = "5"
  }
}

# resource "aws_alb_listener" "listener_443" {
#   load_balancer_arn = aws_alb.load_balancer.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = var.certificate_arn
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_alb_target_group.target_group.arn
#   }
# }

# resource "aws_alb_listener" "listener_80" {
#   load_balancer_arn = aws_alb.load_balancer.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_alb_target_group.target_group.arn

#     # type = "redirect"
#     # redirect {
#     #   port        = "443"
#     #   protocol    = "HTTPS"
#     #   status_code = "HTTP_301"
#     # }
#   }
# }
