provider "aws" {
  region  = "eu-west-3"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key 
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_key_pair" "farah_key" {
  key_name   = "farah-key"
  public_key = file("${path.module}/id_github.pub")
}

resource "aws_security_group" "dev_web_sg" {
  name        = "dev_web_sg"
  description = "Allow SSH and HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "dev_web" {
  ami                    = "ami-0388f26d76e0472c6" # Ubuntu 22.04 LTS - eu-west-3
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.farah_key.key_name
  vpc_security_group_ids = [aws_security_group.dev_web_sg.id]

  tags = {
    Name = "DevWebInstance"
  }
}

resource "aws_s3_bucket" "site_bucket" {
  bucket        = "farah-bucket-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name = "FarahSiteBucket"
  }
}

output "public_ip" {
  description = "Adresse IP publique de l'instance EC2"
  value       = aws_instance.dev_web.public_ip
}
# 👉 Ajoute les variables ici :
variable "aws_access_key" {}
variable "aws_secret_key" {}


