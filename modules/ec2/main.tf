resource "aws_instance" "ec2" {
  ami  = data.aws_ami.centos8.image_id
  instance_type = var.instance_type
  vpc_security_group_ids = ["sg-07d06a948af69411d"]
  // iam_instance_profile = aws_iam_instance_profile.main.name
  subnet_id            = "subnet-0658c46b905e4d8e2"

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
  count   = length(var.dns_name)
  zone_id = "Z0280752N15KXNCY0H6Y"
  name    = element(var.dns_name,count.index )
  name    = var.tool
  type    = "CNAME"
  ttl     = 30
  records = [var.dns_name]

}
resource "aws_lb_listener_rule" "rule" {
  count   = length(var.dns_name)
  listener_arn = var.listener_arn
  priority     = var.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  condition {
    host_header {
      values = ["${element(var.dns_names,count.index)}.jyothsnashrey.online"]
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

