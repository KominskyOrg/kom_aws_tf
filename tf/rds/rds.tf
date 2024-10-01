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
  username               = "admin"
  vpc_security_group_ids = [module.rds_sg.security_group_id]
  subnet_ids             = var.database_subnets
  publicly_accessible    = false

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

module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.org}-rds"
  description = "Allow MySQL traffic"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Allow MySQL access from within the VPC"
      cidr_blocks = var.vpc_cidr_block
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
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = var.tags
}

