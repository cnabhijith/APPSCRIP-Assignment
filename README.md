# 🚀 EKS Cluster Setup and ArgoCD Deployment with GoDaddy DNS Integration


## 📌 1. Install Terraform

Install Terraform using the following command:

```bash
sudo snap install terraform --classic
📌 4. Install AWS CLI
Download and install AWS CLI on the VM:

bash
Copy
Edit
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install
aws configure
📌 5. Install Kubectl
Install kubectl:

bash
Copy
Edit
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-0105/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin
kubectl version --short --client
📌 6. Install EKSCTL
Install eksctl for EKS cluster management:

bash
Copy
Edit
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
📌 7. Save the Script
Save all commands in a file (e.g., ctl.sh) and make it executable:

bash
Copy
Edit
chmod +x ctl.sh
📌 8. Create Terraform Files
Create the following files for your Terraform setup:

css
Copy
Edit
backend.tf
data.tf
main.tf
outputs.tf
provider.tf
terraform.tfvars
variables.tf
📌 9. Run Terraform Commands
Initialize and apply Terraform configurations:

bash
Copy
Edit
terraform init
terraform plan
terraform apply -auto-approve
📌 10. Create EKS Cluster
This step is typically handled by your Terraform configuration in the previous step.

🎯 Set Up ArgoCD on EKS
ArgoCD is a declarative, GitOps-based continuous delivery tool for Kubernetes. Here's how to set it up on your EKS cluster:

1. Install ArgoCD CLI
First, install the ArgoCD CLI to interact with ArgoCD:

bash
Copy
Edit
# Download ArgoCD CLI
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argocd/releases/latest/download/argocd-linux-amd64

# Make it executable
sudo chmod +x /usr/local/bin/argocd

# Verify installation
argocd version
2. Install ArgoCD in the Kubernetes Cluster
bash
Copy
Edit
# Create Namespace
kubectl create namespace argocd

# Install ArgoCD using official manifests
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argocd/stable/manifests/install.yaml

# Verify pods
kubectl get pods -n argocd
3. Expose the ArgoCD Server
Option 1: Port-Forwarding (Quick Setup)

bash
Copy
Edit
kubectl port-forward svc/argocd-server -n argocd 8080:443
Access ArgoCD UI at: https://localhost:8080

Option 2: LoadBalancer (Public Access)

bash
Copy
Edit
kubectl edit svc argocd-server -n argocd
Change:

yaml
Copy
Edit
type: ClusterIP
To:

yaml
Copy
Edit
type: LoadBalancer
Then retrieve external IP:

bash
Copy
Edit
kubectl get svc argocd-server -n argocd
Access ArgoCD UI at: https://<EXTERNAL-IP>

4. Access ArgoCD Web UI
bash
Copy
Edit
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
Login Info:

Username: admin

Password: (retrieved above)

Optional CLI Login:

bash
Copy
Edit
argocd login <ARGOCD_SERVER_IP>
5. Connect a GitHub Repository to ArgoCD
bash
Copy
Edit
argocd app create <app-name> \
--repo <repository-url> \
--path <directory-in-repo> \
--dest-server https://kubernetes.default.svc \
--dest-namespace <k8s-namespace>
Then:

bash
Copy
Edit
argocd app sync <app-name>
argocd app get <app-name>
6. Automate Syncing with GitOps
Enable auto-sync to keep your cluster in sync with your Git repository:

bash
Copy
Edit
argocd app set <app-name> --sync-policy automated
🌐 Step 9: DNS Mapping with GoDaddy Domain
1. Get the Load Balancer DNS Name
Go to EC2 Dashboard → Load Balancers

Copy the DNS name under the Description tab

2. Log In to GoDaddy
Go to GoDaddy and log in.

3. Access Domain Settings
Go to the Domains section

Select the domain

Click to open domain settings

4. Manage DNS Settings
Scroll to DNS Settings

Click Manage DNS

5. Add a CNAME Record
Type: CNAME

Host: www or app

Points to: DNS of Load Balancer

TTL: Default or as required

Click Save

6. Update the A Record (Optional)
To map the root domain (example.com):

Modify or add an A Record to point to the IP address of the Load Balancer

Or use AWS Route 53 for alias mapping

7. Wait for DNS Propagation
Changes may take a few minutes to 24 hours.

Check propagation using: https://www.whatsmydns.net/

8. Test the Setup
After DNS is updated, your GoDaddy domain should route to the application on your EKS cluster.

✅ DNS Resolution Verification (Example Screenshot or Output)
Provide a screenshot or command output here:

bash
Copy
Edit
nslookup <your-domain>
