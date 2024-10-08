resource "aws_security_group" "sg" {
  name        = "${var.env}-${var.component}-sg"
  description = "application security group"
  vpc_id      = var.vpc_id



  ingress {
    description = "HTTP"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_node_cidr
  }

  #   ingress {
  #     description = "PROMETHEUS"
  #     from_port        = 9100
  #     to_port          = 9100
  #     protocol         = "tcp"
  #     cidr_blocks      = [var.prometheus_cidr]
  #   }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env}-${var.component}"
  }
}

resource "aws_iam_role" "iam_role" {
  name = "${var.env}-${var.component}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "${var.env}-${var.component}-policy"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "kms:Decrypt",
            "ssm:DescribeParameters",
            "ssm:GetParameterHistory",
            "ssm:GetParametersByPath",
            "ssm:GetParameters",
            "ssm:GetParameter"
          ],
          "Resource" : "*"
        }
      ]
    })
  }

  tags = {
    tag-key = "${var.env}-${var.component}-role"
  }
}
resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.env}-${var.component}-profile"
  role = aws_iam_role.iam_role.name
}
resource "aws_launch_template" "temp" {
  name          = "${var.env}-${var.component}"
  image_id      = data.aws_ami.ami_id.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }
  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size           = 10
      encrypted             = true
      delete_on_termination = true
    }
  }

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    role_name = var.component,
    env       = var.env
  }))
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.env}-${var.component}"
    }
  }
}


resource "aws_autoscaling_group" "asg" {
  name                = "${var.env}-${var.component}"
  vpc_zone_identifier = var.subnets
  target_group_arns = [aws_lb_target_group.tg.arn]
  max_size            = var.max_size
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity

  launch_template {
    id      = aws_launch_template.temp.id
    version = "$Latest"
  }

  tag {
    key                 = "project"
    propagate_at_launch = false
    value               = "expense"
  }
}

resource "aws_lb_target_group" "tg" {
  name                 = "${var.env}-${var.component}-tg"
  port                 = var.app_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = "30"
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 5
    unhealthy_threshold = 2
    port                = var.app_port
    path                = "/health"
    timeout             = 3

  }
}
