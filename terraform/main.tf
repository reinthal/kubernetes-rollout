# create the private network
resource "hcloud_network" "network" {
  name     = var.private_network_name
  ip_range = var.private_network_ip_range
}

resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.network.id
  type         = "cloud"
  network_zone = var.network_zone
  ip_range     = var.private_network_subnet_range
}

# create the load balancer
resource "hcloud_load_balancer" "controlplane_load_balancer" {
  name               = "talos-lb"
  load_balancer_type = var.load_balancer_type
  network_zone       = var.network_zone
}

# attach the load balancer to the private network
resource "hcloud_load_balancer_network" "srvnetwork" {
  load_balancer_id = hcloud_load_balancer.controlplane_load_balancer.id
  network_id       = hcloud_network.network.id
}

# add the control plane to the load balancer
resource "hcloud_load_balancer_target" "load_balancer_target" {
  type             = "server"
  load_balancer_id = hcloud_load_balancer.controlplane_load_balancer.id
  server_id        = hcloud_server.controlplane_server.id
  use_private_ip   = true
  depends_on = [
    hcloud_server.controlplane_server
  ]
}

# loadbalance kubectl port
resource "hcloud_load_balancer_service" "controlplane_load_balancer_service_kubectl" {
  load_balancer_id = hcloud_load_balancer.controlplane_load_balancer.id
  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443
}

# loadbalance talosctl
resource "hcloud_load_balancer_service" "controlplane_load_balancer_service_talosctl" {
  load_balancer_id = hcloud_load_balancer.controlplane_load_balancer.id
  protocol         = "tcp"
  listen_port      = 50000
  destination_port = 50000
}

# loadbalance mayastor
resource "hcloud_load_balancer_service" "controlplane_load_balancer_service_mayastor" {
  load_balancer_id = hcloud_load_balancer.controlplane_load_balancer.id
  protocol         = "tcp"
  listen_port      = 30011
  destination_port = 30011
}

# Talos
# create the machine secrets
resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version_contract
}

# create the control plane and apply generated config in user_data
resource "hcloud_server" "controlplane_server" {
  name        = "talos-controlplane"
  image       = var.snapshot_id
  server_type = var.controlplane_type
  location    = var.location
  labels      = { type = "talos-controlplane" }
  user_data   = data.talos_machine_configuration.controlplane.machine_configuration
  network {
    network_id = hcloud_network.network.id
  }
  depends_on = [
    hcloud_network_subnet.subnet,
    hcloud_load_balancer.controlplane_load_balancer,
    talos_machine_secrets.this,
  ]
}

# bootstrap the cluster
resource "talos_machine_bootstrap" "bootstrap" {
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = hcloud_server.controlplane_server.ipv4_address
  node                 = hcloud_server.controlplane_server.ipv4_address
}

# create the worker and apply the generated config in user_data
resource "hcloud_server" "worker_server" {
  for_each    = var.workers
  name        = each.value.name
  image       = var.snapshot_id
  server_type = each.value.server_type
  location    = each.value.location
  labels      = { type = "talos-worker" }
  user_data   = data.talos_machine_configuration.worker.machine_configuration
  network {
    network_id = hcloud_network.network.id
  }
  depends_on = [
    hcloud_network_subnet.subnet,
    hcloud_load_balancer.controlplane_load_balancer,
  ]
}

# create the extra ssd volumes and attach them to the worker
resource "hcloud_volume" "volumes" {
  for_each  = hcloud_server.worker_server
  name      = "${each.value.name}-volume"
  size      = var.worker_extra_volume_size
  server_id = each.value.id
  depends_on = [
    hcloud_server.worker_server
  ]
}

# kubeconfig
resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = hcloud_server.controlplane_server.ipv4_address
}