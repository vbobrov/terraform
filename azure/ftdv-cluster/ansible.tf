resource "local_file" "ansible_inv" {
  filename = "ansible-inv.yml"
  content = templatefile("ansible-inv.tftpl", {
    cdo_token  = var.cdo_token
    acp_policy = var.acp_policy
    cluster = "${var.cluster_prefix}-1"
    password = var.admin_password
    node = azurerm_network_interface.fw_management[0].ip_configuration[0].private_ip_address
  })
}

resource "null_resource" "ftd_provision" {
  connection {
    type        = "ssh"
    user        = "azadmin"
    host        = azurerm_public_ip.mgm.ip_address
    private_key = file("~/.ssh/aws-ssh-1.pem")
    agent       = false
  }
  provisioner "file" {
    source      = "${path.module}/ansible-inv.yml"
    destination = "/home/azadmin/ansible-inv.yml"
  }
  provisioner "file" {
    source      = "${path.module}/cdo-onboard.yml"
    destination = "/home/azadmin/cdo-onboard.yml"
  }

  # provisioner "remote-exec" {
  #   inline = [
  #     "ansible-playbook -i /home/azadmin/ansible-inv.yml /home/azadmin/cdo-onboard.yml --extra-vars='cluster_name=${var.cluster_prefix}-1'"
  #   ]
  # }

  depends_on = [
    azurerm_linux_virtual_machine.ftd,
    local_file.ansible_inv
  ]
}