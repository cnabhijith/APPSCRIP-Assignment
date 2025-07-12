Markdown

# EKS Cluster Setup and ArgoCD Deployment

This guide provides a comprehensive walkthrough for setting up an Amazon EKS (Elastic Kubernetes Service) cluster using Terraform, deploying ArgoCD for GitOps-based continuous delivery, and finally, mapping a GoDaddy domain to your application exposed via a Load Balancer.

## Table of Contents

1.  [Prerequisites](#prerequisites)
2.  [EKS Cluster Setup with Terraform](#eks-cluster-setup-with-terraform)
    * [Installation of Tools](#installation-of-tools)
    * [Terraform Configuration Files](#terraform-configuration-files)
    * [Running Terraform](#running-terraform)
3.  [Set Up ArgoCD on EKS](#set-up-argocd-on-eks)
    * [Install ArgoCD CLI](#install-argocd-cli)
    * [Install ArgoCD in the Kubernetes Cluster](#install-argocd-in-the-kubernetes-cluster)
    * [Expose the ArgoCD Server](#expose-the-argocd-server)
    * [Access ArgoCD Web UI](#access-argocd-web-ui)
    * [Connect a GitHub Repository to ArgoCD](#connect-a-github-repository-to-argocd)
    * [Automate Syncing with GitOps](#automate-syncing-with-gitops)
4.  [DNS Mapping with GoDaddy Domain](#dns-mapping-with-godaddy-domain)
    * [Get the Load Balancer DNS Name](#get-the-load-balancer-dns-name)
    * [Log In to GoDaddy](#log-in-to-godaddy)
    * [Access Domain Settings](#access-domain-settings)
    * [Manage DNS Settings](#manage-dns-settings)
    * [Add a CNAME Record](#add-a-cname-record)
    * [Update the A Record (Optional)](#update-the-a-record-optional)
    * [Wait for DNS Propagation](#wait-for-dns-propagation)
    * [Test the Setup](#test-the-setup)

---

## 1. Prerequisites

Before you begin, ensure you have an EC2 instance (or any Linux VM) with `sudo` access.

---

## 2. EKS Cluster Setup with Terraform

This section covers the installation of necessary tools and the steps to provision your EKS cluster using Terraform.

### Installation of Tools

Execute the following commands on your VM to install Terraform, AWS CLI, Kubectl, and Eksctl:

```bash
# Save all commands in a file (e.g., ctl.sh) and make it executable:
# chmod +x ctl.sh

# Install Terraform
sudo snap install terraform --classic

# Install AWS CLI
curl "[https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip](https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip)" -o "awscliv2.zip"
sudo apt install -y unzip
unzip awscliv2.zip
sudo ./aws/install
aws configure # Configure your AWS credentials here

# Install Kubectl
curl -o kubectl [https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl](https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl)
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin
kubectl version --short --client

# Install EKSCTL
curl --silent --location "[https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname](https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname) -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
Terraform Configuration Files
Create the following Terraform files in a dedicated directory for your EKS setup. These files will define your AWS resources, including the EKS cluster.

backend.tf: Configures the Terraform backend (e.g., S3 for state management).

data.tf: Defines data sources.

main.tf: Contains the primary resource definitions for your EKS cluster.

outputs.tf: Defines output values from your Terraform deployment.

provider.tf: Configures the AWS provider.

terraform.tfvars: Stores variable values (e.g., region, cluster name).

variables.tf: Declares input variables.

Example File Structure:

your-eks-project/
├── backend.tf
├── data.tf
├── main.tf
├── outputs.tf
├── provider.tf
├── terraform.tfvars
└── variables.tf
Running Terraform
Navigate to your Terraform project directory and execute the following commands to initialize, plan, and apply your EKS cluster configuration:

Bash

terraform init
terraform plan
terraform apply -auto-approve
Note: The creation of the EKS cluster (Step 10 in the original prompt) is implicitly handled by the terraform apply command if your main.tf file is correctly configured to provision the EKS cluster.

3. Set Up ArgoCD on EKS
ArgoCD is a declarative, GitOps-based continuous delivery tool for Kubernetes. Here's how to set it up on your EKS cluster.

Install ArgoCD CLI
Install the ArgoCD command-line interface (CLI) to interact with ArgoCD:

Bash

# Download ArgoCD CLI
sudo curl -sSL -o /usr/local/bin/argocd [https://github.com/argoproj/argocd/releases/latest/download/argocd-linux-amd64](https://github.com/argoproj/argocd/releases/latest/download/argocd-linux-amd64)

# Make it executable
sudo chmod +x /usr/local/bin/argocd

# Verify the installation
argocd version
Install ArgoCD in the Kubernetes Cluster
Deploy ArgoCD into your EKS cluster:

Bash

# Create a Namespace for ArgoCD
kubectl create namespace argocd

# Install ArgoCD in the argocd Namespace using the official manifests
kubectl apply -n argocd -f [https://raw.githubusercontent.com/argoproj/argocd/stable/manifests/install.yaml](https://raw.githubusercontent.com/argoproj/argocd/stable/manifests/install.yaml)

# Verify the ArgoCD Installation
kubectl get pods -n argocd
Expose the ArgoCD Server
By default, ArgoCD is not accessible from outside the cluster. Choose one of the following options to expose the ArgoCD UI:

Option 1: Port-Forwarding (Quick Setup)
For temporary access from your local machine:

Bash

kubectl port-forward svc/argocd-server -n argocd 8080:443
Access ArgoCD's web UI using your browser at: https://localhost:8080

Option 2: Expose ArgoCD with LoadBalancer (For Public Access)
To make ArgoCD publicly accessible via an AWS Load Balancer:

Edit the argocd-server service to change its type from ClusterIP to LoadBalancer:

Bash

kubectl edit svc argocd-server -n argocd
In the spec section, change type: ClusterIP to type: LoadBalancer and save the changes.

Retrieve the external IP address or DNS name of the Load Balancer:

Bash

kubectl get svc argocd-server -n argocd
Now, you can access ArgoCD UI at: https://<EXTERNAL-IP> (replace <EXTERNAL-IP> with the actual Load Balancer DNS name).

Access ArgoCD Web UI
Get ArgoCD Admin Password:
The default password for the admin user is stored as a secret. Retrieve it using:

Bash

kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
This command will output the initial password. Log in to the ArgoCD UI with the username admin and this password.

Login to ArgoCD via CLI (Optional):
If you want to use the ArgoCD CLI, log in using:

Bash

argocd login <ARGOCD_SERVER_IP>
Replace <ARGOCD_SERVER_IP> with either localhost:8080 (for port-forward) or the external IP/DNS name (if you used a LoadBalancer). Authenticate using:

Username: admin

Password: (retrieved from the secret above)

Connect a GitHub Repository to ArgoCD
Connect your GitHub repository containing Kubernetes manifests or Helm charts to ArgoCD:

Bash

argocd app create <app-name> \
  --repo <repository-url> \
  --path <directory-in-repo> \
  --dest-server [https://kubernetes.default.svc](https://kubernetes.default.svc) \
  --dest-namespace <k8s-namespace>
Replace:

<app-name>: Your application's name (e.g., my-nginx-app).

<repository-url>: The URL of your GitHub repository (e.g., https://github.com/your-org/your-repo.git).

<directory-in-repo>: The directory in your repo that contains Kubernetes manifests or Helm charts (e.g., kubernetes-manifests/dev).

<k8s-namespace>: The Kubernetes namespace where the app should be deployed (e.g., default or my-app-namespace).

Sync the Application to Deploy:

Bash

argocd app sync <app-name>
Monitor the Application:

Bash

argocd app get <app-name>
Automate Syncing with GitOps
By default, ArgoCD follows the GitOps model. Enable automatic syncing for your application:

Bash

argocd app set <app-name> --sync-policy automated
This command ensures that any new changes in the Git repository are automatically deployed to your Kubernetes cluster without manual intervention.

4. DNS Mapping with GoDaddy Domain
To map your Load Balancer's DNS name to a custom domain using GoDaddy, follow these steps:

1. Get the Load Balancer DNS Name
If you're using AWS, go to the EC2 Dashboard > Load Balancers.
Select your load balancer (e.g., the one created by ArgoCD if you exposed it with a LoadBalancer, or your application's Load Balancer).
Find the DNS name under the "Description" tab. Copy this DNS name.

2. Log In to GoDaddy
Go to the GoDaddy website and log in to your account.

3. Access Domain Settings
Once logged in, navigate to the "Domains" section and select the domain name you want to map to your load balancer.
Click on the domain name to access its settings.

4. Manage DNS Settings
Scroll down to the "DNS Settings" section.
Click on "Manage DNS" to open the DNS management page.

5. Add a CNAME Record
In the DNS management page, under the "Records" section, click on "Add" to create a new DNS record.

Type: Choose CNAME.

Host: Enter the subdomain you want to use (e.g., www or app). If you want to map www.yourdomain.com, enter www.

Points to: Paste the DNS name of your load balancer that you copied earlier.

TTL (Time To Live): Set the TTL value (the default is usually fine).

Click Save to apply the changes.

6. Update the A Record (Optional)
If you want to map the root domain (e.g., example.com without www), you may need to update the A Record.
Instead of a CNAME, add or modify the existing A Record to point to the IP address of your load balancer (if available) or use a service like AWS Route 53 to map the root domain to the load balancer (Route 53 supports Alias records for this purpose). For GoDaddy, if you have a static IP for your Load Balancer (uncommon for standard AWS Load Balancers), you could point an A record to it. Otherwise, a CNAME for subdomains is the standard approach.

7. Wait for DNS Propagation
DNS changes can take some time to propagate across the internet, usually within a few minutes to 24 hours.
You can use tools like What's My DNS to check if the changes have propagated globally.

8. Test the Setup
Once DNS propagation is complete, you should be able to access your application using your GoDaddy domain name mapped to the load balancer (e.g., https://www.yourdomain.com).
