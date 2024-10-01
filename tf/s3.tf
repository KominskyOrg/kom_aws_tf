resource "aws_s3_bucket" "tf_state_dev" {
  bucket = "kominskyorg-dev-tf-state"
  tags = {
    Name = "kominskyorg-dev-tf-state"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "tf_state_staging" {
  bucket = "kominskyorg-staging-tf-state"
  tags = {
    Name = "kominskyorg-staging-tf-state"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "tf_state_prod" {
  bucket = "kominskyorg-prod-tf-state"
  tags = {
    Name = "kominskyorg-prod-tf-state"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_dynamodb_table" "tf_lock_dev" {
  name         = "tf-state-lock-dev"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "tf-state-lock-dev"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_dynamodb_table" "tf_lock_staging" {
  name         = "tf-state-lock-staging"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "tf-state-lock-staging"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_dynamodb_table" "tf_lock_prod" {
  name         = "tf-state-lock-prod"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "tf-state-lock-prod"
  }

  lifecycle {
    prevent_destroy = true
  }
}