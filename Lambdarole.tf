#Lambda role & policy attached.
resource "aws_iam_role" "LambdaFunctionRole" {
    assume_role_policy    = jsonencode(
        {
            Statement = [
                {
                    Action    = "sts:AssumeRole"
                    Effect    = "Allow"
                    Principal = {
                        Service = "lambda.amazonaws.com"
                    }
                },
            ]
            Version   = "2012-10-17"
        }
    )
    force_detach_policies = false
    managed_policy_arns   = [
        "arn:aws:iam::aws:policy/AmazonS3FullAccess",
        "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess",
        "arn:aws:iam::aws:policy/CloudWatchFullAccess"
    ]
    name = var.LogRoleName
}