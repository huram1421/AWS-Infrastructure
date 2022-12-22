

# AWS Lambda
resource "aws_lambda_function" "DriverLambda" {
  function_name = "DriverLambda"
  filename         = data.archive_file.lambda_python.output_path
  source_code_hash = data.archive_file.lambda_python.output_base64sha256
  role    = aws_iam_role.iam_for_lambda.arn
  handler = "DriverLambda.lambda_handler"
  runtime = "python3.7"
}


resource "aws_lambda_function" "RiderLambda" {
  function_name = "RiderLambda"
  filename         = data.archive_file.lambda_python.output_path
  source_code_hash = data.archive_file.lambda_python.output_base64sha256
  role    = aws_iam_role.iam_for_lambda.arn
  handler = "RiderLambda.lambda_handler"
  runtime = "python3.7"
}


resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "dynamoDB_policy" {
  name        = "dynamoDB_policy"
  description = "dynamoDB_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:BatchGetItem",
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:BatchWriteItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "role_and_policy_attachement" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.dynamoDB_policy.arn
}



data "archive_file" "lambda_python" {
    type = "zip"
    source_dir  = "${path.module}/lambda_python"
    output_path = "${path.module}/lambda_python.zip"
}