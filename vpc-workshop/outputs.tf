output "instance_ips" {
  type        = list(string)
  value       = aws_instance.main.*.public_ip
  description = "AWS EC2 instance public IP address"
}

output "instance_dns_addresses" {
  type        = list(string)
  value       = aws_instance.main.*.public_dns
  description = "AWS EC2 instance public DNS"
}
