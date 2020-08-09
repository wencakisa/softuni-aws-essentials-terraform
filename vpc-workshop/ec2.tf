# SSH key pair

resource "aws_key_pair" "main" {
  key_name   = "${var.name}-main-key"
  public_key = file(var.public_key_path)
}

# EC2 instance

resource "aws_instance" "main" {
  count                  = var.az_count
  subnet_id              = element(aws_subnet.public.*.id, count.index)
  vpc_security_group_ids = [aws_security_group.main.id]

  ami           = var.ec2_ami
  instance_type = var.ec2_instance_type

  key_name = aws_key_pair.main.key_name

  associate_public_ip_address = true

  user_data = <<EOF
#!/bin/bash
sudo yum install -y epel-release
sudo yum install -y nginx
sudo service nginx start
EOF

  tags = {
    Name = "${var.name}-instance-${count.index}"
  }
}
