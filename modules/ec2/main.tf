resource "aws_instance" "ec2" {
  ami  = data.aws_ami.centos8.image_id
  instance_type = var.instance_type
  vpc_security_group_ids = ["sg-07d06a948af69411d"]
  // iam_instance_profile = aws_iam_instance_profile.main.name
  subnet_id            = "subnet-0658c46b905e4d8e2"
  iam_instance_profile = aws_iam_instance_profile.main.name

  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior  = "stop"
      spot_instance_type = "persistent"
    }
  }


  tags = {
    Name = var.tool
  }
}


resource "aws_route53_record" "record" {
  zone_id = "Z0280752N15KXNCY0H6Y"
  name    = var.tool
  type    = "CNAME"
  ttl     = 30
  records = [var.dns_name]

}
resource "aws_route53_record" "record-private-ec2" {
  zone_id = "Z0280752N15KXNCY0H6Y"
  name    = "${var.tool}-int"
  type    = "A"
  ttl     = 30
  records = [aws_instance.ec2.private_ip] # creating 2 DNS rec0rds one for ALB public IP communication other is Private Ip for internal communication

}
resource "aws_lb_listener_rule" "rule" {
  listener_arn = var.listener_arn
  priority     = var.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  condition {
    host_header {
      values = ["${var.tool}.jyothsnashrey.online"]
    }
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.tool}-tg"
  port     = var.port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "attach" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.ec2.id
  port             = var.port
}



resource "aws_iam_role" "main" {
  name    = "${var.tool}-role"

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


}

resource "aws_iam_instance_profile" "main" {
  name = "${var.tool}-role"
  role = aws_iam_role.main.name
}


