# Partial config: the real values live in backend.hcl (git-ignored).
#   terraform init -backend-config=backend.hcl
# To use local state instead, delete this file before running terraform init.
terraform {
  backend "s3" {}
}
