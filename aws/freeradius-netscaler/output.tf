output "radius_ip" {
  value = aws_network_interface.radius.*.private_ip
}

output "mgm_ip" {
  value = aws_instance.mgm.public_ip
}

output "adc_management" {
  value = aws_network_interface.adc_management.private_ip
}

output "adc_id" {
  value = aws_instance.adc.id
}
