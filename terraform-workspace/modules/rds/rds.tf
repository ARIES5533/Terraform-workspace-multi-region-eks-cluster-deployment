########## Resource: PostgreSQL Database ###########

resource "aws_db_instance" "postgres" {
  identifier = "${terraform.workspace}-olumoko"
  provider              = aws
  allocated_storage     = 20
  engine                = "postgres"
  engine_version        = "16"
  instance_class        = "db.t3.medium"
  username              = var.db_username
  password              = var.db_password
  db_subnet_group_name  = var.db_subnet_group_name
  skip_final_snapshot   = true
  multi_az              = true
  publicly_accessible   = true


  vpc_security_group_ids = [var.db_security_group_id]

  tags = {
    Name = "Olumoko-${terraform.workspace}-PostgreSQL_Database"
  }
}
