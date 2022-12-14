resource "aws_lb_target_group" "churn_target_group" {
  deregistration_delay          = "300"
  load_balancing_algorithm_type = "round_robin"
  name                          = "churn-application-group"
  port                          = 5000
  protocol                      = "HTTP"
  protocol_version              = "HTTP1"
  tags                          = local.tags
  target_type                   = "ip"
  vpc_id                        = aws_vpc.prod-vpc.id
  
  health_check {
    enabled             = true
    healthy_threshold   = 5 
    interval            = 300    # increased 10x to avoid elb health check failed error !!
    matcher             = "200"
    path                = "/health-status"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 120 # increased 24x to avoid elb health check failed error !!!
    unhealthy_threshold = 2
  }

  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }
  depends_on = [
    aws_codebuild_project.churn_build,
  ]
}



resource "aws_lb" "churn_load_balancer" {
  drop_invalid_header_fields = false
  enable_deletion_protection = false
  enable_http2               = true
  idle_timeout               = 180    # increased 3x to avoid elb health check failed error
  internal                   = false
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  name                       = "churn-load-balancer"
  security_groups = [
    aws_security_group.allow_alb.id
  ]
  subnets = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id]
  tags = local.tags
  depends_on = [
    aws_lb_target_group.churn_target_group,
  ]
}

resource "aws_lb_listener" "churn_connection" {
  load_balancer_arn = aws_lb.churn_load_balancer.arn
  port              = "5000" #was80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.churn_target_group.arn
  }
  depends_on = [
    aws_lb.churn_load_balancer,
  ]
}





