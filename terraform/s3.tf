resource "aws_s3_bucket" "wooloo" {
  bucket = "wooloo-prod"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}
