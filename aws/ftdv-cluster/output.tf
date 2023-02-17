output "ftd_management" {
  value = aws_network_interface.ftd_management.*.private_ip
}

output "app1_servers" {
  value = aws_instance.app1_linux.*.private_ip
}

output "app2_servers" {
  value = aws_instance.app2_linux.*.private_ip
}

output "jumphost" {
  value = aws_instance.jumphost.public_ip
}