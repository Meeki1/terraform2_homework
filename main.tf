terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  default_tags {
    tags = {
      Owner = "Khasanshin Airat"
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  user_data = file("userdata.tpl")

  depends_on = [aws_db_instance.wp-db]
}


resource "aws_db_instance" "wp-db" {
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  storage_type           = "gp2"
  allocated_storage      = 20
  max_allocated_storage  = 0
  skip_final_snapshot    = true
  username               = "admin"
  password               = "admin"
}
