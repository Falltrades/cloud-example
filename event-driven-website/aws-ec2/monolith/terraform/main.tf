module "web" {
  source         = "../../../../terraform-modules/aws/ec2-app"
  project        = "event-driven"
  app_port       = 8080
  s3_bucket_name = "event-driven-ansible-bucket"
}

resource "aws_lb_target_group" "ws" {
  name        = "event-driven-ws-tg"
  port        = 3001
  protocol    = "HTTP"
  vpc_id      = module.web.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    port                = "8080"   # reuse main app health check port
    protocol            = "HTTP"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "ws" {
  target_group_arn = aws_lb_target_group.ws.arn
  target_id        = module.web.app_instance_id
  port             = 3001
}

data "aws_lb_listener" "http" {
  load_balancer_arn = module.web.alb_arn
  port              = 80
}

resource "aws_lb_listener_rule" "ws" {
  listener_arn = data.aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ws.arn
  }

  condition {
    path_pattern {
      values = ["/ws"]
    }
  }
}

resource "aws_security_group_rule" "app_allow_ws" {
  type                     = "ingress"
  from_port                = 3001
  to_port                  = 3001
  protocol                 = "tcp"
  security_group_id        = module.web.app_security_group_id
  source_security_group_id = module.web.alb_security_group_id
  description              = "WebSocket from ALB"
}
