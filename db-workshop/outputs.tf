output "bastion_instance_url" {
  value = aws_instance.bastion.public_dns
}

output "bastion_instance_ip" {
  value = aws_instance.bastion.public_ip
}
