terraform {
  required_providers {
    backblaze = {
      source  = "hashicorp/aws"
      version = ">= 3.8.0"
    }
  }
}

provider "backblaze" {
  region = "us-west-002"
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
}
