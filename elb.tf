#--------------------
# internal用のELB
#--------------------

# alb
resource "aws_lb" "sbcntr-alb-internal" {
  name               = "sbcntr-alb-internal-from-TF"
  internal           = true
  load_balancer_type = "application"
  subnets            = [aws_subnet.sbcntr-subnet-private-container-1a.id, aws_subnet.sbcntr-subnet-private-container-1c.id]
  security_groups    = [aws_security_group.sbcntr-sg-internal.id]
}

# listener(blue)
resource "aws_lb_listener" "sbcntr-alb-internal-listener-blue" {
  load_balancer_arn = aws_lb.sbcntr-alb-internal.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sbcntr-tg-sbcntrdemo-blue.arn
  }
}

# listener(green)
resource "aws_lb_listener" "sbcntr-alb-internal-listener-green" {
  load_balancer_arn = aws_lb.sbcntr-alb-internal.arn
  port              = 10080
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sbcntr-tg-sbcntrdemo-green.arn
  }
}

# target group(blue)
resource "aws_lb_target_group" "sbcntr-tg-sbcntrdemo-blue" {
  name        = "sbcntr-tg-sbcntrdemo-blue-TF"
  protocol    = "HTTP"
  port        = 80
  target_type = "ip"
  vpc_id      = aws_vpc.sbcntr-vpc.id
  health_check {
    path                = "/healthcheck"
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = "200"
  }
}

# target group(green)
resource "aws_lb_target_group" "sbcntr-tg-sbcntrdemo-green" {
  name        = "sbcntr-tg-sbcntrdemo-green-TF"
  protocol    = "HTTP"
  port        = 80
  target_type = "ip"
  vpc_id      = aws_vpc.sbcntr-vpc.id
  health_check {
    path                = "/healthcheck"
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "sbcntr-alb-target-group-attachment-blue" {
  target_group_arn = aws_lb_target_group.sbcntr-tg-sbcntrdemo-blue.arn
  target_id        = "10.0.8.100"
}

resource "aws_lb_target_group_attachment" "sbcntr-alb-target-group-attachment-green" {
  target_group_arn = aws_lb_target_group.sbcntr-tg-sbcntrdemo-green.arn
  target_id        = "10.0.8.101"
}

