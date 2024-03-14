terraform {
  backend "s3" {
    bucket         = "terraform-bucket3"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "sprints3"
  }
}
