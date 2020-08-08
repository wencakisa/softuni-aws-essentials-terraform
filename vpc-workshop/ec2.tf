# SSH key pair

resource "aws_key_pair" "main" {
  key_name   = "${var.name}-main-key"
  public_key = file(var.public_key_path)
}

# EC2 instance

resource "aws_instance" "main" {
  ami           = var.ami
  instance_type = "t2.micro"

  subnet_id = aws_subnet.public.id

  key_name                    = aws_key_pair.main.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.main.id]

  user_data = <<EOF
#!/bin/bash
sudo yum install -y epel-release
sudo yum install -y nginx
sudo service nginx start
EOF

  tags = {
    Name = "${var.name}-instance"
  }
}
