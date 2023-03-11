resource "aws_lambda_function" "lambda-scan" {
  function_name = "scan"
  filename         = data.archive_file.lambda-functions.output_path
  source_code_hash = data.archive_file.lambda-functions.output_base64sha256
  role    = aws_iam_role.role_for_lambda.arn
  handler = "scan.lambda_handler"
  runtime = "python3.9"
}

resource "aws_lambda_function" "lambda-search" {
  function_name = "search"
  filename         = data.archive_file.lambda-functions.output_path
  source_code_hash = data.archive_file.lambda-functions.output_base64sha256
  role    = aws_iam_role.role_for_lambda.arn
  handler = "search.lambda_handler"
  runtime = "python3.9"
}

resource "aws_lambda_function" "lambda-order" {
  function_name = "order"
  filename         = data.archive_file.lambda-functions.output_path
  source_code_hash = data.archive_file.lambda-functions.output_base64sha256
  role    = aws_iam_role.role_for_lambda.arn
  handler = "order.lambda_handler"
  runtime = "python3.9"
}

resource "aws_lambda_function" "lambda-fitch" {
  function_name = "fitch"
  filename         = data.archive_file.lambda-functions.output_path
  source_code_hash = data.archive_file.lambda-functions.output_base64sha256
  role    = aws_iam_role.role_for_lambda.arn
  handler = "fitch.lambda_handler"
  runtime = "python3.9"
}

resource "aws_iam_role" "role_for_lambda" {
    name               = "Our_iam_role_for_lambda"
    assume_role_policy = data.aws_iam_policy_document.role.json
}

resource "aws_iam_role_policy" "lambda_policy" {
    name = "Our_lambda_policy"
    role = aws_iam_role.role_for_lambda.id
    policy = data.aws_iam_policy_document.policy_for_lambda.json
}
