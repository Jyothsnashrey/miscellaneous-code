terraform {
  backend "s3" {
    bucket = "jyo-terraform"
    key    = "misc/elk/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_ami" "centos8" {
  most_recent = true
  name_regex  = "Centos-8-DevOps-Practice"
  owners      = ["973714476881"]
}



resource "aws_instance" "elasticsearch" {
  ami  = data.aws_ami.centos8.image_id
  instance_type = "m6in.large"
  vpc_security_group_ids = ["sg-07d06a948af69411d"]
 // iam_instance_profile = aws_iam_instance_profile.main.name
  subnet_id            = "subnet-0658c46b905e4d8e2"

  instance_market_options{
    spot_options {
      instance_interruption_behaviour= "stop"
      spot_instance_type = "persistent"
   }
 }


  tags = {
    Name = "elasticsearch"
  }
}


resource "aws_route53_record" "elasticsearch" {
  zone_id = "Z0280752N15KXNCY0H6Y"
  name    = "elasticsearch"
  type    = "A"
  ttl     = 30
  records = [aws_instance.elasticsearch.public_ip]

}


