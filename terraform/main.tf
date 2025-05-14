terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "hcloud" {
  token = var.hetzner_api_key
}

# Create 3 Omni nodes
resource "hcloud_server" "omni_nodes" {
  count       = 3
  name        = "omni-node-${count.index + 1}"
  server_type = var.server_type
  image       = var.image
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.id]
  
  # Use user_data to bootstrap the nodes for Omni/Talos
  user_data = templatefile("${path.module}/templates/cloudinit.yaml", {
    node_name = "omni-node-${count.index + 1}"
    node_role = count.index == 0 ? "control-plane" : "worker"
  })

  labels = {
    role = count.index == 0 ? "control-plane" : "worker"
  }
}

# SSH key for accessing the servers
resource "hcloud_ssh_key" "default" {
  name       = "omni-ssh-key"
  public_key = var.ssh_public_key
}

# Create a network for the nodes
resource "hcloud_network" "omni_network" {
  name     = "omni-network"
  ip_range = "10.0.0.0/16"
}

# Create a subnet within the network
resource "hcloud_network_subnet" "omni_subnet" {
  network_id   = hcloud_network.omni_network.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

# Attach servers to the network
resource "hcloud_server_network" "omni_network_attachment" {
  count      = 3
  server_id  = hcloud_server.omni_nodes[count.index].id
  network_id = hcloud_network.omni_network.id
  
  # Remove the explicit IP assignment and let Hetzner assign IPs automatically
  # ip         = "10.0.0.${count.index + 10}"
  
  # Make sure the subnet is created before attaching servers
  depends_on = [hcloud_network_subnet.omni_subnet]
}

# Output the server IPs
output "server_ips" {
  value = {
    for idx, server in hcloud_server.omni_nodes : server.name => {
      public_ip  = server.ipv4_address
      private_ip = hcloud_server_network.omni_network_attachment[idx].ip
      role       = idx == 0 ? "control-plane" : "worker"
    }
  }
} 