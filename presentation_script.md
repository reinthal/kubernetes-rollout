# Kubernetes Infrastructure Project - Progress Report

## Introduction (2 min)
- Good morning/afternoon, I'm here to present the progress made on our Kubernetes infrastructure project
- The goal was to set up a Kubernetes cluster with Talos OS/Sidero Omni, developer boxes, and a deployment pipeline
- While we didn't complete all objectives within the timeframe, I'll walk you through what we did accomplish and the challenges encountered

## Account Setup & Configuration (3 min)
- Successfully created and configured a Sidero Omni account for Talos OS management
- Set up a Tailscale account for secure networking and SSH access
- These accounts provide the foundation for our secure infrastructure

## Infrastructure Provisioning with Terraform (4 min)
- Developed Terraform scripts to automate infrastructure provisioning on Hetzner Cloud
- Created a network configuration with proper subnets and security settings
- Provisioned 3 Omni nodes with appropriate roles:
  - 1 control-plane node
  - 2 worker nodes
- Setup includes SSH key management and proper resource tagging
- The infrastructure follows the infrastructure-as-code principles, making it reproducible and maintainable

## Kubernetes Cluster Configuration (3 min)
- Successfully set up a Kubernetes cluster on top of our Talos OS nodes
- Initial authentication to the cluster with kubectl was established
- Implemented proper role-based access control

## Continuous Delivery with FluxCD (3 min)
- Configured FluxCD for GitOps-based continuous delivery
- Set up the bootstrap process to connect our GitHub repository to the Kubernetes cluster
- Created the directory structure for infrastructure, apps, and configuration
- This approach enables declarative infrastructure and application management through Git

## Challenges & Pending Items (3 min)
1. Developer Box Setup:
   - Encountered issues with the Hetzner CSI provider compatibility with Talos OS, further research needed to be resolved
   - Need more investigation to properly integrate storage for developer environments

2. Authentication Issues:
   - Faced challenges with the OIDC login plugin in our devenv.nix configuration
   - Fixed this issue with 

3. Full GitOps Implementation:
   - Initial FluxCD setup is complete, but needs further configuration for automation of continous deployment of the HAP-CTF image with image automation in fluxCD
   - Would need to finish the configuration for Terraform and Tailscale


## Why did I fail?

- I failed because I lacked knowledge in the particular Talos+Omni Stack which consumed significant time
- Lesson Learned: Once I got Kubectl access i should have focused on deploying the developerboxes instead of Tailscale Operator+FluxCD.


## Next Steps (2 min)
- Resolve the CSI provider issues for developer box storage
- Set up the HAP-CTF deployment and monitoring (Using Prometheous + Grafana stack)

## Conclusion (1 min)
- The foundation of our infrastructure is in place with Terraform and Kubernetes
- We have a solid GitOps approach with FluxCD
- With a few more days of work, we can complete the remaining objectives and have a fully functional, maintainable infrastructure

## Q&A (as needed) 