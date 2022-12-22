# EC2 Instance
resource "aws_instance" "ec2_public" {

  ami           = "ami-0b0dcb5067f052a63"

  instance_type = "t3.micro"

  availability_zone = "us-east-1a"

  associate_public_ip_address = "true"

  key_name = aws_key_pair.ec2_key_pair.id

  subnet_id = var.vpc_public_subnet

  security_groups = [aws_security_group.security_group.id]

  # Connection is needed for provisioner
  connection {
            type        = "ssh"
            user        = "ec2-user"
            private_key = tls_private_key.rsa.private_key_pem
            host        = self.public_ip
  }

  # upload key pair
  provisioner "file" {
    source = "ec2_key_pair"
    destination = "/home/ec2-user/ec2_key_pair"
  }

  # Upload File
  provisioner "file" {
    source = "go_setup.yml"
    destination = "/home/ec2-user/go_setup.yml"
  }

  # Upload File
  provisioner "file" {
    source = "hosts.yml"
    destination = "/home/ec2-user/hosts.yml"
  }

  # Upload File
  provisioner "file" {
    source = "api.go"
    destination = "/home/ec2-user/api.go"
  }

   # Upload File
  provisioner "file" {
    source = "deleteTableItem.go"
    destination = "/home/ec2-user/deleteTableItem.go"
  }

   # Upload File
  provisioner "file" {
    source = "getTableItem.go"
    destination = "/home/ec2-user/getTableItem.go"
  }
   # Upload File
  provisioner "file" {
    source = "logic.go"
    destination = "/home/ec2-user/logic.go"
  }
   # Upload File
  provisioner "file" {
    source = "putTableItem.go"
    destination = "/home/ec2-user/putTableItem.go"
  }


  user_data = <<EOF
  #! /bin/bash
  sudo amazon-linux-extras install ansible2 -y
  sudo yum install golang -y
  chmod 400 ec2_key_pair
  ssh-agent bash
  cp ec2_key_pair ~/.ssh/
  ssh-add ~/.ssh/ec2_key_pair
  export ANSIBLE_HOST_KEY_CHECKING=False
  EOF

  tags = {
    Name = "Infrastructure Public EC2"
  }

}

resource "aws_instance" "ec2_private" {

  ami           = "ami-0b0dcb5067f052a63"

  instance_type = "t3.micro"

  availability_zone = "us-east-1a"

  associate_public_ip_address = "false"

  key_name = aws_key_pair.ec2_key_pair.id

  subnet_id = var.vpc_private_subnet

  private_ip = "10.0.1.50"

  security_groups = [aws_security_group.security_group.id]

  tags = {
    Name = "Infrastructure Private EC2"
  }
}



# create a key pair
resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "ec2_key_pair"
  public_key = tls_private_key.rsa.public_key_openssh
}


# generates a local file with the given content.
# this is the private key pair to be stored in SSH Client
resource "local_file" "ec2_key_pair" {
    content  = tls_private_key.rsa.private_key_pem
    filename = "ec2_key_pair"
}


# key pair type
# there are two key pairs:
# private key pair should be in the SSH Client
# public key pair should be attached to the SSH Server
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Security Group
resource "aws_security_group" "security_group" {

  name        = "Security Group"

  description = "EC2 instance security group"

  vpc_id      = var.vpc

  # inbound
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # Source
  }

  # # inbound
  # ingress {
  #   description      = "HTTP"
  #   from_port        = 80
  #   to_port          = 80
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"] # Source
  # }

  # # inbound
  # ingress {
  #   description      = "SSH"
  #   from_port        = 22
  #   to_port          = 22
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"] # Source
  # }

  # # inbound
  # ingress {
  #   description      = "ICMP"
  #   from_port        = -1
  #   to_port          = -1
  #   protocol         = "icmp"
  #   cidr_blocks      = ["0.0.0.0/0"] # Source
  # }


  ingress {
    description      = "all"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"] # Source
  }

  # outbound
  egress {
    description      = ""
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # if "-1", from_port, to_port must be 0
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

