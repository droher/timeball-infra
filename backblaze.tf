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

resource "aws_s3_bucket" "b" {
  bucket = "timeball"
}
