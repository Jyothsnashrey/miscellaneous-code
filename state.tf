terraform {
  backend "s3" {
    bucket = "jyo-terraform"
    key    = "misc/sonarqube/terraform.tfstate"
    region = "us-east-1"
  }
}