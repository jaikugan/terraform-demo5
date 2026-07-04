terraform {
  backend "s3" {
    bucket       = "my-terraform-state-bucket-development-us-east-1-3"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}