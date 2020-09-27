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
    
    endpoints {
    s3 = "https://s3.us-west-002.backblazeb2.com"
  }
}

resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
