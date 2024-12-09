terraform {
  required_version = ">= 1.3.9"

#   backend "s3" {
#     bucket         = "devops-task-tf-statefiles"
#     region         = "eu-central-1"
#     encrypt        = true
#     key            = "terraform/aws/environments/dev/devops-task/terraform.tfstate"
#     dynamodb_table = "devops-task-tf-state-lock"
#   }
}
