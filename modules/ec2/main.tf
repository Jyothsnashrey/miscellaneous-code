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
  zone_id = "Z0280752N15KXNCY0H6Y"
  name    = var.tool
  type    = "A"
  ttl     = 30
  records = [aws_instance.ec2.public_ip]

}


