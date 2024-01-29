terraform {
  backend "s3" {
    bucket = "jyo-terraform"
    key    = "mis/prometheus/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_ami" "centos8" {
  most_recent = true
  name_regex  = "Centos-8-DevOps-Practice"
  owners      = ["973714476881"]
}



resource "aws_instance" "prometheus" {
  ami           = data.aws_ami.centos8.image_id
  instance_type = "t3.small"
  vpc_security_group_ids = ["sg-07d06a948af69411d"]

  tags = {
    name = "prometheus-server"
  }
}


resource "aws_route53_record" "prometheus" {
  zone_id = "Z0280752N15KXNCY0H6Y"
  name    = "prometheus"
  type    = "A"
  ttl     = 300
  records = [aws_instance.prometheus.private_ip]
}

