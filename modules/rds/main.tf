resource "aws_db_subnet_group" "this" {
  name       = "bookstore-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "bookstore-db-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier              = "bookstore-db-instance"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = var.db_instance_class
  allocated_storage       = 20
  storage_type            = "gp2"
  db_name                    = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [var.vpc_security_group_id]
  skip_final_snapshot     = true

  tags = {
    Name = "bookstore-db"
  }
}
