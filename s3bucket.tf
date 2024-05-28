resource "aws_s3_bucket" "s3logsforbmtrat" {
    bucket = var.S3BucketName

    tags = {
    Name        = "${var.S3BucketName}"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_policy" "buket-policy" {
    bucket = aws_s3_bucket.s3logsforbmtrat.id
    policy = jsonencode(
        {
            Statement = [
                {
                    Action    = "s3:GetBucketAcl"
                    Effect    = "Allow"
                    Principal = {
                        Service = "logs.us-east-1.amazonaws.com"
                    }
                    Resource  = [
                        "arn:aws:s3:::${var.S3BucketName}",
                        "arn:aws:s3:::${var.S3BucketName}/*",
                    ]
                },
                {
                    Action    = "s3:PutObject"
                    Condition = {
                        StringEquals = {
                            "s3:x-amz-acl" = "bucket-owner-full-control"
                        }
                    }
                    Effect    = "Allow"
                    Principal = {
                        Service = "logs.us-east-1.amazonaws.com"
                    }
                    Resource  = [
                        "arn:aws:s3:::${var.S3BucketName}",
                        "arn:aws:s3:::${var.S3BucketName}/*",
                    ]
                },
            ]
            Version   = "2012-10-17"
        }
    )

    depends_on = [ aws_s3_bucket.s3logsforbmtrat ]
}