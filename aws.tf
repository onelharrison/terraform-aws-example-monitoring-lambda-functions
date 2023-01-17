variable "env_name" {
  description = "Environment name"
}

variable "alarms_delivery_email" {
  description = "Email address for alarms"
}

data "aws_ecr_repository" "profile_faker_ecr_repo" {
  name = "profile-faker"
}

resource "aws_lambda_function" "profile_faker_function" {
  function_name = "profile-faker-${var.env_name}"
  timeout       = 5 # seconds
  image_uri     = "${data.aws_ecr_repository.profile_faker_ecr_repo.repository_url}:${var.env_name}"
  package_type  = "Image"

  role = aws_iam_role.profile_faker_function_role.arn

  environment {
    variables = {
      ENVIRONMENT = var.env_name
    }
  }
}

resource "aws_iam_role" "profile_faker_function_role" {
  name = "profile-faker-${var.env_name}"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "profile_faker_lambda_errors" {
  alarm_name          = "${aws_lambda_function.profile_faker_function.function_name}_errors"
  alarm_description   = "Lambda function errors"
  namespace           = "AWS/Lambda"
  statistic           = "Sum"
  metric_name         = "Errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "1"
  evaluation_periods  = "4"
  datapoints_to_alarm = "1"
  period              = "3600"
  treat_missing_data  = "ignore"
  alarm_actions       = toset([aws_sns_topic.profile_faker_function_alarms.arn])
  ok_actions          = toset([aws_sns_topic.profile_faker_function_alarms.arn])

  dimensions = {
    FunctionName = aws_lambda_function.profile_faker_function.function_name
  }
}

resource "aws_sns_topic" "profile_faker_function_alarms" {
  name = "profile-faker-${var.env_name}_alarms"
}

resource "aws_sns_topic_subscription" "profile_faker_function_email_alerts" {
  topic_arn = aws_sns_topic.profile_faker_function_alarms.arn
  protocol  = "email"
  endpoint  = var.alarms_delivery_email
}
