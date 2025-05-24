# Terraform Backend Configuration
# This stores the Terraform state in S3 for team collaboration and CI/CD

terraform {
  backend "s3" {
    bucket         = "lti-project-terraform-state"  # Change this to your unique bucket name
    key            = "terraform/state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lti-project-terraform-locks"  # Change this to your table name
    encrypt        = true
    
    # Optional: Use versioning and lifecycle policies
    versioning = true
  }
}

# S3 Bucket for Terraform State (create this manually first time)
# You can create these resources manually or with a separate Terraform config:
#
# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "lti-project-terraform-state"
#   
#   tags = {
#     Name        = "Terraform State"
#     Environment = var.environment
#     Project     = var.project_name
#   }
# }
#
# resource "aws_s3_bucket_versioning" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }
#
# resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id
#   
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }
#
# resource "aws_dynamodb_table" "terraform_locks" {
#   name           = "lti-project-terraform-locks"
#   billing_mode   = "PAY_PER_REQUEST"
#   hash_key       = "LockID"
#   
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
#   
#   tags = {
#     Name        = "Terraform Locks"
#     Environment = var.environment
#     Project     = var.project_name
#   }
# } 