#--------------------
# internal用のELB
#--------------------

# alb
resource "aws_lb" "sbcntr_alb_internal" {
  name               = "sbcntr-alb-internal-from-TF"
  internal           = true
  load_balancer_type = "application"
  subnets            = [aws_subnet.sbcntrSubnetPrivateContainer1A.id, aws_subnet.sbcntrSubnetPrivateContainer1C.id]
  security_groups    = [aws_security_group.sbcntrSgInternal.id]
}

# listener(blue)
resource "aws_lb_listener" "sbcntr_alb_internal_listener_blue" {
  load_balancer_arn = aws_lb.sbcntr_alb_internal.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sbcntr_tg_sbcntrdemo_blue.arn
  }
}

# target group(blue)
resource "aws_lb_target_group" "sbcntr_tg_sbcntrdemo_blue" {
  name        = "sbcntr-tg-sbcntrdemo-blue-TF"
  protocol    = "HTTP"
  port        = 80
  target_type = "ip"
  vpc_id      = aws_vpc.sbcntrVpc.id
  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = "200"
  }
}

resource "aws_lb_target_group_attachment" "sbcntr_alb_target_group_attachment_blue" {
  target_group_arn = aws_lb_target_group.sbcntr_tg_sbcntrdemo_blue.arn
  target_id        = "10.0.8.100"
}

