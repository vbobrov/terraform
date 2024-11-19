provider "aws" {
  default_tags {
    tags = {
      Example = basename(path.cwd)
      Project = "radius-netscaler"
    }
  }
}