output "fmc_public" {
  value = aws_instance.fmc.public_ip
}

output "fmc_private" {
  value = aws_instance.fmc.private_ip
}

output "ftd_management" {
  value = aws_network_interface.ftd_management.private_ip
}

output "ftd_public" {
  value = aws_eip.outside.public_ip
}

output "password" {
  value = var.admin_password!=""?"Password is supplied in a variable":nonsensitive(random_password.password.result)
}