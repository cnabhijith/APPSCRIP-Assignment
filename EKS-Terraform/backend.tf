terraform {
  backend "s3" {
    bucket = "cicd-terraform-eks"
    key    = "eks/terraform.tfstate"
    region = "ap-south-1"
    state_locking = true
    encrypt = true
    dynamodb_table = "terraform-state-lock"
    dynamodb_region = "ap-south-1"
  }
}