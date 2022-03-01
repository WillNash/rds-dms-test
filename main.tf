provider "random" {}

resource "random_pet" "name" {}


provider "aws" {
  profile = "default"
  region  = "ap-southeast-2"
}

resource "aws_db_parameter_group" "dms_test_terraform" {
  name = "dms-test-terraform"
  family = "mysql5.7"
  parameter {
    name  = "binlog_checksum"
    value = "NONE"
  }
  parameter {
    name  = "binlog_format"
    value = "ROW"
  }
}

resource "aws_instance" "web" {
  ami                    = "ami-0f39d06d145e9bb63"
  instance_type          = "t2.micro"
 # user_data              = file("init-script.sh")

  tags = {
    Name = random_pet.name.id
  }
}


resource "aws_db_instance" "dms_mysql_target" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "dms_target"
  username             = "admin"
  password             = "password"
  parameter_group_name = aws_db_parameter_group.dms_test_terraform.name
  skip_final_snapshot  = true
}

resource "aws_db_instance" "dms_mysql_source" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "dms_source"
  username             = "admin"
  password             = "password"
  parameter_group_name = aws_db_parameter_group.dms_test_terraform.name
  skip_final_snapshot  = true
}
