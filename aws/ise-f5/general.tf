locals {
  tags = {
    "Example" : basename(path.cwd)
    "Project" : "ise"
  }
}

resource "random_password" "password" {
  length      = 10
  special     = false
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
}
