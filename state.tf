terraform {
  backend "s3" {
    bucket = "jyo-terraform"
    key    = "misc-code/all/terraform.tfstate"
    region = "us-east-1"
  }
}