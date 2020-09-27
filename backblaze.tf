provider "aws" {
  region = "us-west-002"
}

resource "aws_s3_bucket" "b" {
  bucket = "timeball"
}
