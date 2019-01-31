variable "server_type_node" {
  default = "g6-standard-2"
}
variable "nodes" {
  default = 3
}
variable "server_type_master" {
  default = "g6-standard-2"
}
variable "region" {
  default = "us-east"
}
variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}
variable "linode_token" {
  default = ""
}
module "k8s" {
  source  = "git::https://github.com/linode/terraform-linode-k8s.git?ref=for-cli"

  linode_token = "${var.linode_token}"

  linode_group = "k8s-beta"

  server_type_node = "${var.server_type_node}"

  nodes = "${var.nodes}"

  server_type_master = "${var.server_type_master}"

  region = "${var.region}"

  ssh_public_key = "${var.ssh_public_key}"
}
