terraform {
  backend "s3" {
    bucket = "gyenoch77-terraform-remote-state"
    key    = "devops/database/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state-lock"
  }
}

# resource "aws_dynamodb_table" "terraform_lock" {
#   name           = "terraform-lock"
#   billing_mode   = "PAY_PER_REQUEST"
#   hash_key       = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }