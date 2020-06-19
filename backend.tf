data "aws_availability_zones" "available" {
}

provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {}
}
