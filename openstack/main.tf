#####################################################################
##
##      Created 2/20/19 by admin. for openstack
##
#####################################################################

## REFERENCE {"openstack_network_default":{"type": "openstack_reference_network"}}

terraform {
  required_version = "> 0.8.0"
}

provider "openstack" {
  user_name   = "${var.openstack_user_name}"
  password    = "${var.openstack_password}"
  tenant_name = "${var.openstack_project_name}"
  domain_name = "${var.openstack_domain_name}"
  auth_url    = "${var.openstack_auth_url}"
  region      = "${var.openstack_region}"
  insecure    = true
  version = "~> 1.2"
}


resource "openstack_compute_instance_v2" "tomcat_instance_1" {
  name      = "${var.tomcat_instance_1_name}"
  image_name  = "${var.openstack_image_name}"
  flavor_name = "${var.openstack_flavor_name}"
  key_pair  = "${openstack_compute_keypair_v2.auth.id}"
  security_groups = ["${openstack_networking_secgroup_v2.group_name.id}"]
  network {
    uuid = "${var.openstack_network_id}"
  }
}

resource "tls_private_key" "ssh" {
    algorithm = "RSA"
}

resource "openstack_compute_keypair_v2" "auth" {
    name = "${var.openstack_key_pair_name}"
    public_key = "${tls_private_key.ssh.public_key_openssh}"
}

resource "openstack_networking_secgroup_v2" "group_name" {
  name        = "group_name"
  description = "TODO"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8080
  port_range_max    = 8080
  remote_ip_prefix  = "192.168.0.1/24"
  security_group_id = "${openstack_networking_secgroup_v2.group_name.id}"
}