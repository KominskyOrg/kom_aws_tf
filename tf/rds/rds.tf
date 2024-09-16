module "db_secret" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "1.1.2"

  name_prefix                      = "${var.org}-${var.env}-db-password"
  description                      = "Secret for RDS database password"
  recovery_window_in_days          = 30
  create_random_password           = true
  random_password_length           = 16
  random_password_override_special = "!@#$%^&*()_+"

  tags = var.tags
}

data "aws_secretsmanager_secret" "db_secret" {
  name = module.db_secret.secret_arn
}

data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.9.0"

  identifier             = "${var.org}-${var.env}-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t4g.micro"
  allocated_storage      = 20
  max_allocated_storage  = 50
  storage_type           = "gp2"
  db_name                = "kom_dev_db"
  username               = "admin"
  password               = data.aws_secretsmanager_secret_version.db_secret.secret_string
  vpc_security_group_ids = [module.rds_sg.security_group_id]
  subnet_ids             = module.vpc.database_subnets
  publicly_accessible    = true

  multi_az                              = false
  backup_retention_period               = 1
  maintenance_window                    = "Mon:00:00-Mon:03:00"
  enabled_cloudwatch_logs_exports       = []
  create_cloudwatch_log_group           = false
  performance_insights_enabled          = false
  performance_insights_retention_period = 7

  skip_final_snapshot              = false
  final_snapshot_identifier_prefix = "${var.org}-${var.env}-db"

  create_db_subnet_group = true
  major_engine_version   = "8.0"
  family                 = "mysql8.0"

  tags = merge(var.tags, {
    "Sensitive" = "high"
  })
}

variable "local_ip" {}

module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.org}-rds"
  description = "Allow MySQL traffic"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Allow MySQL access from within the VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Allow MySQL access from var machine"
      cidr_blocks = var.local_ip
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Allow outbound MySQL traffic to var machine"
      cidr_blocks = var.local_ip
    },
  ]

  tags = var.tags
}

