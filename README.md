Install AWS CLI
Download and install AWS CLI on the VM:



curl "[https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip](https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip)" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install
aws configure
Install Kubectl
Install kubectl:



curl -o kubectl [https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl](https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl)
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin
kubectl version --short --client
Install EKSCTL
Install eksctl for EKS cluster management:



curl --silent --location "[https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname](https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname) -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
Save the Script
Save all commands (for prerequisite installations) in a file (e.g., ctl.sh) and make it executable:



chmod +x ctl.sh
📌 2. Create Terraform Files
Create the following files for your Terraform setup. These files will define your AWS infrastructure, including the EKS cluster.

backend.tf

data.tf

main.tf

outputs.tf

provider.tf

terraform.tfvars

variables.tf

📌 3. Run Terraform Commands
Initialize and apply your Terraform configurations to provision the EKS cluster and associated resources.



terraform init
terraform plan
terraform apply -auto-approve
📌 4. Create EKS Cluster
This step is typically handled by your Terraform configuration in the previous step. Terraform will provision the EKS cluster as defined in your .tf files.

📌 Set Up ArgoCD on EKS
ArgoCD is a declarative, GitOps-based continuous delivery tool for Kubernetes. Here's how to set it up on your EKS cluster:

1. Install ArgoCD CLI
First, install the ArgoCD CLI to interact with ArgoCD:

Download ArgoCD CLI:


sudo curl -sSL -o /usr/local/bin/argocd [https://github.com/argoproj/argocd/releases/latest/download/argocd-linux-amd64](https://github.com/argoproj/argocd/releases/latest/download/argocd-linux-amd64)
Make it executable:



sudo chmod +x /usr/local/bin/argocd
Verify installation




argocd version
2. Install ArgoCD in the Kubernetes Cluster
Create Namespace:



kubectl create namespace argocd
Install ArgoCD using official manifests:



kubectl apply -n argocd -f [https://raw.githubusercontent.com/argoproj/argocd/stable/manifests/install.yaml](https://raw.githubusercontent.com/argoproj/argocd/stable/manifests/install.yaml)
Verify pods:



kubectl get pods -n argocd
3. Expose the ArgoCD Server
Option 1: Port-Forwarding (Quick Setup)

This option is suitable for local access and testing.



kubectl port-forward svc/argocd-server -n argocd 8080:443
Access ArgoCD UI at: https://localhost:8080

Option 2: LoadBalancer (Public Access)

This option exposes ArgoCD via an AWS Load Balancer, providing public access.



kubectl edit svc argocd-server -n argocd
Change:

YAML

type: ClusterIP
To:

YAML

type: LoadBalancer
Then retrieve external IP:



kubectl get svc argocd-server -n argocd
Access ArgoCD UI at: https://<EXTERNAL-IP>

4. Access ArgoCD Web UI
Retrieve the initial admin password:



kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
Login Info:

Username: admin

Password: (retrieved above)

Optional CLI Login:



argocd login <ARGOCD_SERVER_IP>
5. Connect a GitHub Repository to ArgoCD
Create an ArgoCD application to connect your Git repository:



argocd app create <app-name> \
--repo <repository-url> \
--path <directory-in-repo> \
--dest-server [https://kubernetes.default.svc](https://kubernetes.default.svc) \
--dest-namespace <k8s-namespace>
Then synchronize the application:



argocd app sync <app-name>
argocd app get <app-name>
6. Automate Syncing with GitOps
Enable auto-sync to keep your cluster in sync with your Git repository:



argocd app set <app-name> --sync-policy automated
🌐 Step 9: DNS Mapping with GoDaddy Domain
To make your application accessible via a custom domain, integrate it with GoDaddy DNS.

1. Get the Load Balancer DNS Name
Go to the AWS EC2 Dashboard and navigate to "Load Balancers". Copy the DNS name listed under the "Description" tab for your ArgoCD Load Balancer.

2. Log In to GoDaddy
Go to GoDaddy and log in to your account.

3. Access Domain Settings
Navigate to the "Domains" section, select your domain, and click to open its domain settings.

4. Manage DNS Settings
Scroll down to "DNS Settings" and click on "Manage DNS".

5. Add a CNAME Record
Add a new CNAME record with the following details:

Type: CNAME

Host: www or app (or any subdomain you prefer)

Points to: The DNS name of your Load Balancer (copied in step 1)

TTL: Default or as required

Click "Save".

6. Update the A Record (Optional)
To map the root domain (e.g., example.com), you can either:

Modify or add an A Record to point to the IP address of the Load Balancer.

Or, if using AWS Route 53, configure an alias record to point to the Load Balancer.

7. Wait for DNS Propagation
DNS changes may take a few minutes to up to 24 hours to propagate across the internet.

8. Test the Setup
After DNS propagation is complete, your GoDaddy domain should now route to the application running on your EKS cluster.

✅ DNS Resolution Verification (Output)
You can verify the DNS resolution using nslookup:
