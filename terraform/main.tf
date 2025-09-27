
resource "aws_instance" "app_server" {
  ami           = "ami-0c1a7f89451184c8b" # Amazon Linux 2 AMI in ap-south-1
  instance_type = "t2.micro"
  key_name      = "mern-key"
  subnet_id     = data.aws_subnet_ids.default.ids[0]
  associate_public_ip_address = true
  security_groups = [aws_security_group.app_sg.name]
  tags = {
    Name = "MERN-App-Server"
  }
}

resource "aws_instance" "db_server" {
  ami           = "ami-0c1a7f89451184c8b"
  instance_type = "t2.micro"
  key_name      = "mern-key"
  subnet_id     = data.aws_subnet_ids.default.ids[0]
  associate_public_ip_address = true
  security_groups = [aws_security_group.db_sg.name]
  tags = {
    Name = "MongoDB-Server"
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow HTTP, HTTPS, SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow MongoDB only from app server"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

output "app_server_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "db_server_public_ip" {
  value = aws_instance.db_server.public_ip
}
