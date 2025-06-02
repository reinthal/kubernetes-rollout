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
    ip         = var.controlplane_ip
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
    ip         = each.value.ip
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

# resource "kubernetes_secret" "hcloud_token" {
#   metadata {
#     name      = "hcloud-token"
#     namespace = "kube-system"
#   }

#   data = {
#     token = var.hetzner_api_key
#   }

#   type = "Opaque"

#   depends_on = [
#     null_resource.wait_for_kubernetes,
#     talos_machine_bootstrap.bootstrap
#   ]
# }

# resource "kubernetes_deployment" "hcloud_ccm" {
#   metadata {
#     name      = "hcloud-cloud-controller-manager"
#     namespace = "kube-system"
#   }

#   spec {
#     selector {
#       match_labels = {
#         app = "hcloud-cloud-controller-manager"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           app = "hcloud-cloud-controller-manager"
#         }
#       }

#       spec {
#         service_account_name = "cloud-controller-manager"
#         dns_policy          = "Default"
#         priority_class_name = "system-cluster-critical"

#         container {
#           name  = "hcloud-cloud-controller-manager"
#           image = "hetznercloud/hcloud-cloud-controller-manager:v1.18.0"

#           command = ["/bin/hcloud-cloud-controller-manager"]
#           args    = [
#             "--cloud-provider=hcloud",
#             "--leader-elect=true",
#             "--allow-untagged-cloud"
#           ]

#           env {
#             name = "NODE_NAME"
#             value_from {
#               field_ref {
#                 field_path = "spec.nodeName"
#               }
#             }
#           }

#           env {
#             name = "HCLOUD_TOKEN"
#             value_from {
#               secret_key_ref {
#                 name = "hcloud-token"
#                 key  = "token"
#               }
#             }
#           }
#         }

#         toleration {
#           key    = "node.cloudprovider.kubernetes.io/uninitialized"
#           value  = "true"
#           effect = "NoSchedule"
#         }

#         toleration {
#           key    = "CriticalAddonsOnly"
#           operator = "Exists"
#         }

#         toleration {
#           key    = "node-role.kubernetes.io/master"
#           effect = "NoSchedule"
#         }
#       }
#     }
#   }

#   depends_on = [
#     kubernetes_secret.hcloud_token,
#     talos_machine_bootstrap.bootstrap
#   ]
# }

# resource "null_resource" "create_talosconfig" {
#   provisioner "local-exec" {
#     command = <<-EOT
#       echo "${data.talos_client_configuration.this.talos_config}" > /tmp/talosconfig
#     EOT
#   }
# }

# resource "null_resource" "wait_for_kubernetes" {
#   provisioner "local-exec" {
#     command = <<-EOT
#       echo "Waiting for Kubernetes API to be ready..."

#       # Set talos config
#       export TALOSCONFIG=/tmp/talosconfig

#       # Wait for all nodes to be ready
#       timeout 300 bash -c 'until talosctl --nodes ${hcloud_server.controlplane_server.ipv4_address} health --server=false; do sleep 10; done'

#       # Wait for Kubernetes API to respond and get kubeconfig
#       timeout 300 bash -c 'until talosctl --nodes ${hcloud_server.controlplane_server.ipv4_address} kubeconfig; do sleep 10; done'

#       # Ensure kubeconfig is updated
#       talosctl --nodes ${hcloud_server.controlplane_server.ipv4_address} kubeconfig --force

#       # Clean up temporary talos config
#       rm -f /tmp/talosconfig

#       echo "Kubernetes cluster is ready!"
#     EOT
#   }

#   depends_on = [
#     null_resource.create_talosconfig,
#     talos_machine_bootstrap.bootstrap,
#     hcloud_server.worker_server,
#     data.talos_client_configuration.this
#   ]
# }