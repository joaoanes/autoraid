
terraform {
  backend "s3" {
    bucket = "autoraid-tf-backend"
    key    = "state.tf"
    region = "eu-central-1"
  }
}
