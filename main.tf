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

resource "aws_instance" "db_management" {
  ami                    = "ami-0f39d06d145e9bb63"
  instance_type          = "t2.micro"
 # user_data             = file("init-script.sh")
  key_name               = aws_key_pair.dms_management_key.key_name
  vpc_security_group_ids = [aws_security_group.dms_database_sg.id]
  tags = {
    Name = random_pet.name.id
  }
}

resource "aws_key_pair" "dms_management_key" {
  key_name   = "dms_management_key"
  public_key = file("id_rsa.pub")
}

resource "aws_security_group" "dms_database_sg" {
  name = "dms_rds_talk"
  description = "Allow target and source to communicate with replication instance and inbound traffic from Will."
  
  ingress {
    description = "Connection from Will."
    cidr_blocks = ["150.107.172.210/32"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"     
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol   = "-1"
  } 
}
/*
resource "aws_db_instance" "dms_mysql_target" {
  allocated_storage      = 10
  engine                 = "mysql"
  identifier             = "dms-target"
  publicly_accessible    = true
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  name                = "dms_target"
  username               = "admin"
  password               = "password"
  parameter_group_name   = aws_db_parameter_group.dms_test_terraform.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.dms_database_sg.id]
}

resource "aws_db_instance" "dms_mysql_source" {
  allocated_storage      = 10
  engine                 = "mysql"
  identifier             = "dms-source"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  publicly_accessible    = true
  name                = "dms_source"
  username               = "admin"
  password               = "password"
  parameter_group_name   = aws_db_parameter_group.dms_test_terraform.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.dms_database_sg.id]
}

*/
  

