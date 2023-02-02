output "ise_ip" {
  value = aws_instance.ise.*.private_ip
}

output "mgm_ip" {
  value = aws_instance.mgm.public_ip
}

output "f5_management" {
  value = aws_network_interface.f5_management.private_ip
}

output "password" {
  value = nonsensitive(random_password.password.result)
}