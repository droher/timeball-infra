terraform {
  required_providers {
    backblaze = {
      source  = "hashicorp/aws"
      version = ">= 3.8.0"
    }
  }
}

provider "backblaze" {
  region = var.backblaze_region
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
}
