# =============================================================================
# TALOS MACHINE CONFIGURATIONS
# =============================================================================

# create the controlplane config, using the loadbalancer as cluster endpoint
data "talos_machine_configuration" "controlplane" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${hcloud_load_balancer.controlplane_load_balancer.ipv4}:6443"
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version_contract
  kubernetes_version = var.kubernetes_version
  config_patches = [
    templatefile("${path.module}/templates/controlplanepatch.yaml.tmpl", {
      loadbalancerip = hcloud_load_balancer.controlplane_load_balancer.ipv4, 
      subnet = var.private_network_subnet_range
    }),
    templatefile("${path.module}/templates/hcloud-managerpatch.yaml.tmpl", {})
  ]
  depends_on = [
    hcloud_load_balancer.controlplane_load_balancer
  ]
}

# create the worker config and apply the worker patch
data "talos_machine_configuration" "worker" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${hcloud_load_balancer.controlplane_load_balancer.ipv4}:6443"
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version_contract
  kubernetes_version = var.kubernetes_version
  config_patches = [
    templatefile("${path.module}/templates/workerpatch.yaml.tmpl", {
      subnet = var.private_network_subnet_range
    }),
    templatefile("${path.module}/templates/hcloud-managerpatch.yaml.tmpl", {})
  ]
  depends_on = [
    hcloud_load_balancer.controlplane_load_balancer
  ]
}

# =============================================================================
# TALOS CLIENT CONFIGURATION
# =============================================================================

# create the talos client config
data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints = [
    hcloud_load_balancer.controlplane_load_balancer.ipv4
  ]
}