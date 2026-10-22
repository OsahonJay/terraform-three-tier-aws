# One-off: creates the S3 bucket that holds remote state for the main stack.
# Run once with local state, then never destroy it while the main stack exists.

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "three-tier"
      Purpose   = "terraform-state"
      ManagedBy = "terraform"
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "state" {
  #checkov:skip=CKV_AWS_18:Access logging needs a second bucket; versioning already keeps every state change
  #checkov:skip=CKV_AWS_144:Cross-region replication is overkill for a single-user lab state bucket
  #checkov:skip=CKV2_AWS_62:No consumer for S3 event notifications on a state bucket
  # Account ID keeps the name globally unique without guessing.
  bucket = "${var.bucket_prefix}-${data.aws_caller_identity.current.account_id}-${var.aws_region}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      # aws:kms with no key ID uses the AWS-managed aws/s3 key: KMS encryption with no key to manage.
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    id     = "expire-old-state-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

variable "aws_region" {
  description = "Region for the state bucket."
  type        = string
  default     = "eu-west-2"
}

variable "bucket_prefix" {
  description = "Prefix for the state bucket name."
  type        = string
  default     = "three-tier-tfstate"
}

output "state_bucket_name" {
  description = "Put this in backend.hcl as the bucket value."
  value       = aws_s3_bucket.state.bucket
}
