# aws_lambda_function.JHLambdaLogsToS3:
resource "aws_lambda_function" "lambda-function" {
    filename                       = "${path.module}/Lambda.zip"
    function_name                  = var.LambdaFunctionName
    role                           = aws_iam_role.LambdaFunctionRole.arn
    runtime                        = "python3.9"
    handler                        = "index.lambda_handler"
    timeout                        = 5

    environment {
        variables = {
            "GROUP_NAME"            = var.LogGroupName
            "NUM_DAYS"              = "1"
            "PREFIX"                = "sample"
            "S3_DESTINATION_BUCKET" = var.S3BucketName
        }
    }
    #source_code_hash = "${base64sha256(file("${path.module}/Lambda.zip"))}"

    ephemeral_storage {
        size = 512
    }

    logging_config {
        log_format = "Text"
    }

    tracing_config {
        mode = "PassThrough"
    }

    depends_on = [ aws_s3_bucket.s3logsforbmtrat ]
}


module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"

  create_bus = false

   rules = {
    crons = {
        description = "Run state machine everyday 10:10 UTC"
        schedule_expression = "cron(10 10 ? * * *)"
    }
   }

   targets = {
    crons = [
      {
        name  = "event-to-lambda"
        arn   = "${aws_lambda_function.lambda-function.arn}"
        id = "TargetFunctionV1"
      }
    ]
  }

  depends_on = [ aws_lambda_function.lambda-function ]
}

resource "aws_lambda_permission" "EventsToInvokeLambda" {
  statement_id  = "PermissionForEventsToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = var.LambdaFunctionName
  principal     = "events.amazonaws.com"
  source_arn    = module.eventbridge.eventbridge_rule_arns.crons

  depends_on = [ 
    aws_s3_bucket.s3logsforbmtrat,
    aws_lambda_function.lambda-function
    ]
}