output "DriverLambdaArn" {
  value       = aws_lambda_function.DriverLambda.invoke_arn
}
output "DriverLambdaName" {
    value = aws_lambda_function.DriverLambda.function_name
}

output "RiderLambdaArn" {
  value       = aws_lambda_function.RiderLambda.invoke_arn
}
output "RiderLambdaName" {
    value = aws_lambda_function.RiderLambda.function_name
}