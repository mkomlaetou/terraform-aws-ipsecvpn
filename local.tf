locals {
  default_tags = {
    IacTool = "terraform"
  }
  tags = merge(local.default_tags, var.custom_tags)
}


