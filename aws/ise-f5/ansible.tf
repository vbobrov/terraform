resource "local_file" "ansible_inv" {
  filename = "ansible-inv.yml"
  content = templatefile("ansible-inv.tftpl", {
    username = "iseadmin"
    password = random_password.password.result
    nodes = [for i in range(var.ise_count) :
      {
        "fqdn" : "ise-${i + 1}.aws.ciscodemo.net",
        "role" : i == 0 ? "primary" : "secondary"
      }
    ]
    f5_list        = "'[${join(",", [for f in range(length([aws_network_interface.f5_internal.private_ip])) : "{\"name\":\"f5-${f + 1}\",\"ip\":\"${[aws_network_interface.f5_internal.private_ip][f]}\"}"])}]'"
    secondary_list = "'[${join(",", [for s in range(2, var.ise_count + 1) : "{\"fqdn\":\"ise-${s}.aws.ciscodemo.net\",\"roles\":[${s == 2 ? "\"SecondaryAdmin\",\"SecondaryMonitoring\"" : ""}],\"services\":[\"Session\",\"Profiler\"]}"])}]'"
    ca_cert        = replace(replace(file(var.root_ca_file), "\n", "\\n"), "\r", "")
    system_cert    = replace(replace(file(var.system_ca_file), "\n", "\\n"), "\r", "")
    system_key     = replace(replace(file(var.system_key_file), "\n", "\\n"), "\r", "")
  })
}

resource "null_resource" "ise_provision" {
  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = aws_instance.mgm.public_ip
    private_key = file("~/.ssh/aws-ssh-1.pem")
    agent       = false
  }
  provisioner "file" {
    source      = "${path.module}/ansible-inv.yml"
    destination = "/home/ec2-user/ansible-inv.yml"
  }
  provisioner "file" {
    source      = "${path.module}/ise-provision.yml"
    destination = "/home/ec2-user/ise-provision.yml"
  }
  provisioner "remote-exec" {
    inline = ["ansible-playbook -i /home/ec2-user/ansible-inv.yml /home/ec2-user/ise-provision.yml"]
  }
  depends_on = [
    aws_instance.ise,
    local_file.ansible_inv
  ]
}