provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Repo      = "your-org/your-repo"
    }
  }
}
