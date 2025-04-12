resource "aws_lb" "webapp_alb" {
  name               = "webapp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public_subnet[*].id


  tags = {
    Name = "webapp-alb"
  }
}

resource "aws_lb_target_group" "webapp_tg" {
  name        = "webapp-tg"
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.primary_vpc.id


  health_check {
    path                = "/healthz"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# resource "aws_lb_listener" "webapp_listener" {
#   load_balancer_arn = aws_lb.webapp_alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.webapp_tg.arn
#   }
# }

# resource "aws_lb_listener" "dev_https_listener" {
#   load_balancer_arn = aws_lb.webapp_alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"

#   certificate_arn = data.aws_acm_certificate.dev_cert.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.webapp_tg.arn
#   }
# }

# resource "aws_lb_listener" "demo_https_listener" {
#   load_balancer_arn = aws_lb.webapp_alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"

#   # certificate_arn = aws_acm_certificate_import.demo_cert.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.webapp_tg.arn
#   }
# }


// Define an HTTPS listener that references the target group.
// This active listener ensures that traffic is forwarded to the target group,
// so the target group will no longer be marked as "Unused".
resource "aws_lb_listener" "app_https_listener" {
  load_balancer_arn = aws_lb.webapp_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  // Use the ACM certificate retrieved from the data source (in acm_dev.tf)
  certificate_arn = var.profile == "dev" ? var.dev_certificate_arn : var.demo_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_tg.arn
  }
}