packer {
  required_plugins {
    hcloud = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/hcloud"
    }
  }
}

locals {
  image = "hcloud-amd64-omni-reinthal-v1.9.5.raw.xz"
}

source "hcloud" "talos" {
  rescue       = "linux64"
  image        = "debian-11"
  location     = "nbg1"
  server_type  = "cx22"
  ssh_username = "root"

  snapshot_name = "Omni Image"
}

build {
  sources = ["source.hcloud.talos"]

  provisioner "file" {
    source = "${local.image}"
    destination = "/tmp/talos.raw.xz"
  }

  provisioner "shell" {
    inline = [
      "xz -d -c /tmp/talos.raw.xz | dd of=/dev/sda && sync",
    ]
  }
}
