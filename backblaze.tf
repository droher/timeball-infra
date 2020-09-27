provider "aws" {
  alias = "backblaze"
  region = "us-west-002"
}

resource "aws_s3_bucket" "b" {
  bucket = "timeball"
}
