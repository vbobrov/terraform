resource "local_file" "ansible_inv" {
  filename = "ansible-inv.yml"
  content = templatefile("ansible-inv.tftpl", {
    cdo_token = var.cdo_token
    acp_policy = var.acp_policy
    clusters = {
      for c in range(local.fw_az_count): "lab-cluster-${c+1}" => [aws_network_interface.ftd_management[c*var.fw_per_az].private_ip]
    }
  })
}

resource "null_resource" "ftd_provision" {
  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = aws_instance.jumphost.public_ip
    private_key = file("~/.ssh/aws-ssh-1.pem")
    agent       = false
  }
  provisioner "file" {
    source      = "${path.module}/ansible-inv.yml"
    destination = "/home/ec2-user/ansible-inv.yml"
  }
  provisioner "file" {
    source      = "${path.module}/cdo-onboard.yml"
    destination = "/home/ec2-user/cdo-onboard.yml"
  }
  provisioner "file" {
    source      = "${path.module}/ftd-onboard.yml"
    destination = "/home/ec2-user/ftd-onboard.yml"
  }
  provisioner "remote-exec" {
    inline = ["ansible-playbook -i /home/ec2-user/ansible-inv.yml /home/ec2-user/cdo-onboard.yml"]
  }
  depends_on = [
    aws_instance.ftd,
    local_file.ansible_inv
  ]
}