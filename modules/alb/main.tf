resource "aws_security_group" "sg" {
  name        = "${var.env}-${var.alb_type}-sg"
  description = "application security group"
  vpc_id      = var.vpc_id



  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.allow_sg_cidr]
  }
#
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.allow_sg_cidr]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env}-${var.alb_type}"
  }
}

resource "aws_lb" "alb" {
  name               = "${var.env}-${var.alb_type}"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = var.subnet

  tags = {
    Environment = "${var.env}-${var.alb_type}"
  }
}

resource "aws_route53_record" "main" {
  zone_id = var.zone_id
  name    = var.dns_name
  type    = "CNAME"
  ttl     = 30
  records = [aws_lb.alb.dns_name]
}

resource "aws_lb_listener" "listener-http-public" {
  count             = var.alb_type == "public" ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_lb_listener" "listener-http-private" {
  count             = var.alb_type == "private" ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.tg_arn
  }
}

resource "aws_lb_listener" "listener-https" {
  count             = var.alb_type == "public" ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:471112727668:certificate/369b897c-9964-48fe-87e5-e324f5245b5a"


  default_action {
    type             = "forward"
    target_group_arn = var.tg_arn
  }
}