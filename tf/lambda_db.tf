resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:UpdateSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],

        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "rds:*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetRandomPassword"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_attach_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

data "aws_secretsmanager_secret_version" "rds_master_password" {
  secret_id = module.rds.db_secret_arn
}

resource "aws_lambda_function" "manage_db_resources" {
  filename         = "../lambda_functions/manage_db_resources_v1.5.zip"
  function_name    = "manage_db_resources"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "manage_db_resources.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60
  memory_size      = 256

  environment {
    variables = {
      RDS_HOST        = module.rds.db_host
      RDS_PORT        = module.rds.db_port
      MASTER_USERNAME = jsondecode(data.aws_secretsmanager_secret_version.rds_master_password.secret_string)["username"]
      MASTER_PASSWORD = jsondecode(data.aws_secretsmanager_secret_version.rds_master_password.secret_string)["password"]
    }
  }

  vpc_config {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  depends_on = [module.rds]
}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda_sg"
  description = "Security group for Lambda to access RDS"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group_rule" "allow_lambda_to_rds" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.rds.db_security_group_id
  source_security_group_id = aws_security_group.lambda_sg.id
}


# Output Lambda ARN
output "manage_db_resources_lambda_arn" {
  description = "ARN of the generic manage_db_resources Lambda function"
  value       = aws_lambda_function.manage_db_resources.arn
}
