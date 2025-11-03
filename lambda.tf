data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/" # Compacta tudo na pasta 'src'
  output_path = "${path.module}/dist/lambda.zip"
}

resource "aws_lambda_function" "s3_file_purger" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.project_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60 # 60 segundos para cold start da VPC
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      CLOUDFLARE_API_TOKEN = var.cloudflare_api_token
      CLOUDFLARE_ZONE_ID   = var.cloudflare_zone_id
      CLOUDFLARE_DOMAIN    = var.cloudflare_domain_name
    }
  }

  # Configuração de Rede para usar o NAT Gateway
  vpc_config {
    # Usamos a função 'split' para transformar a string em uma lista
    subnet_ids         = split(",", var.vpc_subnet_ids)
    security_group_ids = split(",", var.vpc_security_group_ids)
  }
}

# Permissão para o S3 invocar a Lambda
resource "aws_lambda_permission" "allow_s3_to_invoke" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_file_purger.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.s3_bucket_name}"
}

# Configuração da notificação no S3
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.s3_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_file_purger.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }

  # Garante que a permissão seja criada antes da notificação
  depends_on = [aws_lambda_permission.allow_s3_to_invoke]
}