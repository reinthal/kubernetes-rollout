output "talosconfig" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}

output "worker_load_balancer_ip" {
  value       = hcloud_load_balancer.worker_load_balancer.ipv4
  description = "Public IP address of the worker load balancer for HTTPS traffic"
}