locals {
  tags = {
    "Example" : basename(path.cwd)
    "Project" : "FTD FMC Simple"
  }
}

resource "random_password" "password" {
  length      = 8
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special = 1
  override_special = "!"
}