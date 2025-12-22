resource "aws_db_instance" "postgres" {
  engine            = "postgres"
  instance_class    = "db.t3.small"
  allocated_storage = 20
  username          = "myadmin"
  password          = "password123"
  multi_az          = true
  skip_final_snapshot = true
}
