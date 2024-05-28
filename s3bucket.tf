resource "aws_s3_bucket" "s3logsforbmtrat" {
    bucket = var.S3BucketName
}

resource "aws_s3_bucket_policy" "buket-policy" {
    bucket = var.S3BucketName
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
                        "arn:aws:s3:::s3logsforbmtrat",
                        "arn:aws:s3:::s3logsforbmtrat/*",
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
                        "arn:aws:s3:::s3logsforbmtrat",
                        "arn:aws:s3:::s3logsforbmtrat/*",
                    ]
                },
            ]
            Version   = "2012-10-17"
        }
    )
}