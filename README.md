# Baseline

- [ ] Kubernetes on Talos OS / Sidero Omni
- [ ] Devboxes that can run nix hello

# Application deployment

- [ ] run https://github.com/palisaderesearch/hap-ctf container with HPA
      autoscaling

# Stretch: reliability


[ x  x  x  x  x  x  x  >  0  0  0  0  0  0  0  0]

Open-ended stretch: reliability

7. Implement basic monitoring with Prometheus and Grafana
8. Configure automated alerts for critical system metrics
9. Set up a backup strategy for critical components

# summary of tasks

1. Provision 3 Omni nodes on Hetzner Cloud. Use Terraform.

```
Build 'hcloud.talos' finished after 4 minutes 27 seconds.

==> Wait completed after 4 minutes 27 seconds

==> Builds finished. The artifacts of successful builds are:
--> hcloud.talos: A snapshot was created: 'Omni Image' (ID: 237425437)
```

2. Provision a Kubernetes cluster with 1 control node and 2 workers
3. Provision developer boxes
4. Set up access to dev boxes with Tailscale SSH bonus: set up GitOps for
   Terraform and Tailscale

5. Deploy HAP-CTF HTTP API and expose it with cloudflared
6. Set up continuous delivery for HAP-CTF bonus: set up auto updates for
   developer box image

7. Implement basic monitoring with Prometheus and Grafana
8. Configure automated alerts for critical system metrics
9. Set up a backup strategy for critical components

# Baseline (7 Pomodoros)

- [x] Provision 3 Omni nodes with Terraform: 2 Pomodoros (50 min)
- [x] Add tailscale to my own machine
- [x] Configure Tailscale for my omni nodes
- [x] Provision Kubernetes cluster: 2 Pomodoros (50 min)
- [x] authenticate to the cluster using kubectl and kubelogin
![image](https://github.com/user-attachments/assets/a02c5ba7-606e-47b8-b1b4-b94f7b858645)


- [ ] Provision developer boxes: 2 Pomodoros (50 min)
- [ ] Set up Tailscale SSH access: 1 Pomodoro (25 min)

# Expansion (4 Pomodoros)

- [ ] Deploy HAP-CTF HTTP API with cloudflared: 2 Pomodoros (50 min)
- [ ] Set up continuous delivery: 2 Pomodoros (50 min)

- [ ] Stretch Goals (4 Pomodoros)

- [ ] Implement Prometheus and Grafana: 2 Pomodoros (50 min)
- [ ] Configure automated alerts: 1 Pomodoro (25 min)
- [ ] Set up backup strategy: 1 Pomodoro (25 min)

# Buffer (1 Pomodoro)

- [ ] patch devenv.nix to include the oidc-login plugin
- Troubleshooting/unexpected issues: 1 Pomodoro (25 min)
