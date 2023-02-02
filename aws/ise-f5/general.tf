locals {
  tags = {
    "Example" : basename(path.cwd)
    "Project" : "ise"
  }
}

resource "random_password" "password" {
  length  = 10
  special = false
}
