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
  default = "/home/chris/.ssh/id_rsa.pub"
}
module "k8s" {
  source  = "git::https://github.com/linode/terraform-linode-k8s.git?ref=for-cli"

  linode_token = "0c6d09dd263e681c2d6546de6a3d269c538331491483d811880dda570dd03db2"
  
  linode_group = "kafKaMGxRRb-codeforphilly"

  server_type_node = "${var.server_type_node}"

  nodes = "${var.nodes}"

  server_type_master = "${var.server_type_master}"

  region = "${var.region}"

  ssh_public_key = "${var.ssh_public_key}"
}
