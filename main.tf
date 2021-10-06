terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}
variable "pvt_key" {}
variable "pub_key" {}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "tf-master" {
  name = "tf-master"
}

resource "digitalocean_droplet" "workstation" {
  image = "ubuntu-20-04-x64"
  name = "workstation"
  region = "sfo3" 
  size = "s-1vcpu-1gb"
  tags = ["workstation"]
  ssh_keys = [data.digitalocean_ssh_key.tf-master.id]
  
  connection {
    host = self.ipv4_address
    type = "ssh"
    user = "root"
    private_key = file(var.pvt_key)
  }

  provisioner "file" {
    source = var.pvt_key
    destination = "tf-master"
  }

  provisioner "file" {
    source = var.pub_key
    destination = "tf-master.pub"
  }

  provisioner "file" {
    source = "apache-install.yml"
    destination = "apache-install.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt -y install software-properties-common",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo apt -y install ansible",
      "chmod 600 ${var.pvt_key}",
      "chmod 600 ${var.pub_key}",
    ]
  }

  provisioner "file" {
    content = templatefile("hosts.tpl", { 
      names = {
        for droplet in digitalocean_droplet.web:
        droplet.name => droplet.name
      },
      ipv4_addrs = {
        for droplet in digitalocean_droplet.web:
        droplet.name => droplet.ipv4_address
    }})
    destination = "/etc/ansible/hosts"
  }

  provisioner "remote-exec" {
    inline = [
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key}' apache-install.yml"
    ]
  }
}

resource "digitalocean_droplet" "web" {
  count = 3
  image = "ubuntu-20-04-x64"
  name = "web-${count.index}"
  region = "sfo3" 
  size = "s-1vcpu-1gb"
  tags = ["terraform"]
  ssh_keys = [data.digitalocean_ssh_key.tf-master.id]
}

output "ipv4_address_workstation" {
  value = digitalocean_droplet.workstation.ipv4_address
}

output "ipv4_address_web" {
  value = {
    for droplet in digitalocean_droplet.web:
    droplet.name => droplet.ipv4_address
  }
}