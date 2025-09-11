terraform {
  backend "s3" {
    bucket  = "unique-sreops-bucket"
    key     = "terraform/state/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}