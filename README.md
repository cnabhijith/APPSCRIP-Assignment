# Install Terraform 
Install Terraform using the following command: 
sudo snap install terraform --classic 
4. Install AWS CLI 
Download and install AWS CLI on the VM: 
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o 
"awscliv2.zip" 
sudo apt install unzip 
unzip awscliv2.zip 
sudo ./aws/install 
aws configure 
5. Install Kubectl 
Install kubectl: 
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01
05/bin/linux/amd64/kubectl 
chmod +x ./kubectl 
sudo mv ./kubectl /usr/local/bin 
kubectl version --short --client 
6. Install EKSCTL 
Install eksctl for EKS cluster management: 
curl --silent --location 
"https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(una
 me -s)_amd64.tar.gz" | tar xz -C /tmp 
sudo mv /tmp/eksctl /usr/local/bin 
eksctl version 
7. Save the Script 
Save all commands in a file (e.g., ctl.sh) and make it executable: 
chmod +x ctl.sh 
8. Create Terraform Files 
Create the following files for your Terraform setup: 
o main.tf 
o output.tf 
o variables.tf 
9. Run Terraform Commands 
Initialize and apply Terraform configurations: 
terraform init 
terraform plan 
terraform apply -auto-approve 
10. Create EKS Cluster 



 8: Set Up ArgoCD on EKS 
ArgoCD is a declarative, GitOps-based continuous delivery tool for Kubernetes. 
Here's how to set it up on your EKS cluster: 
1. Install ArgoCD CLI 
First, install the ArgoCD command-line interface (CLI) to interact with ArgoCD 
from your local environment or the EC2 instance: 
# Download ArgoCD CLI 
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo
cd/releases/latest/download/argocd-linux-amd64 
 
# Make it executable 
sudo chmod +x /usr/local/bin/argocd 
 
# Verify the installation 
argocd version 
 
2. Install ArgoCD in the Kubernetes Cluster 
To deploy ArgoCD in your EKS cluster, follow these steps: 
1. Create a Namespace for ArgoCD: 
kubectl create namespace argocd 
2. Install ArgoCD in the argocd Namespace: 
Use the following command to install ArgoCD using the official manifests: 
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo
cd/stable/manifests/install.yaml 

3. Verify the ArgoCD Installation: 
You can verify the installation by checking the status of ArgoCD pods: 
kubectl get pods -n argocd 
This will show a list of ArgoCD components such as argocd-server, argocd-repo
server, argocd-application-controller, and argocd-dex-server. 
 
3. Expose the ArgoCD Server 
By default, ArgoCD is not accessible from outside the cluster. To expose the 
ArgoCD UI, you can use a LoadBalancer service or a port-forward command. 
Option 1: Port-Forwarding (Quick Setup) 

1. Run the following command to access the ArgoCD UI via localhost:8080: 
kubectl port-forward svc/argocd-server -n argocd 8080:443 

2. Access ArgoCD's web UI using your browser at: 
https://localhost:8080 
Option 2: Expose ArgoCD with LoadBalancer (For Public Access) 

1. Edit the ArgoCD argocd-server service to switch from ClusterIP to 
LoadBalancer: 
kubectl edit svc argocd-server -n argocd 

2. In the spec section, change type: ClusterIP to type: LoadBalancer 
and save the changes. 
This will make the ArgoCD UI accessible via an external IP 
address. 

3. Retrieve the external IP address: 
kubectl get svc argocd-server -n argocd 
Now, you can access ArgoCD UI at: 
https://<EXTERNAL-IP> 
 
4. Access ArgoCD Web UI 
1. Get ArgoCD Admin Password: 

The default password for the admin user is stored as a secret. Retrieve it using the 
following command: 

kubectl get secret argocd-initial-admin-secret -n argocd -o 
jsonpath="{.data.password}" | base64 -d 

This will return the initial password. You can log in to the ArgoCD UI with the 
username admin and this password. 
2. Login to ArgoCD via CLI (Optional): 
If you want to use the ArgoCD CLI, log in using the following command: 
argocd login <ARGOCD_SERVER_IP> 
Replace <ARGOCD_SERVER_IP> with either localhost:8080 (for port-forward) or 
the external IP (if you used a LoadBalancer). 
Authenticate using: 
o Username: admin 
o Password: (retrieved from the secret above) 
 
5. Connect a GitHub Repository to ArgoCD 
Now that ArgoCD is installed, the next step is to connect your GitHub repository 
with Kubernetes manifests or Helm charts. 
1. Create a New ArgoCD Application: 
argocd app create <app-name> \ --repo <repository-url> \ --path <directory-in-repo> \ --dest-server https://kubernetes.default.svc \ --dest-namespace <k8s-namespace> 
Replace: 
o <app-name> with your application's name. 
o <repository-url> with the URL of your GitHub repository. 
o <directory-in-repo> with the directory in your repo that contains 
Kubernetes manifests or Helm charts. 
o <k8s-namespace> with the Kubernetes namespace where the app 
should be deployed. 
2. Sync the Application to Deploy: 
After creating the application, sync it with the following command to deploy your 
application to Kubernetes: 
argocd app sync <app-name> 
3. Monitor the Application: 
Check the status of the application deployment using: 
argocd app get <app-name> 
 
6. Automate Syncing with GitOps 
By default, ArgoCD follows the GitOps model, where changes to your Git 
repository automatically sync with your Kubernetes cluster. 
1. Enable Auto-Sync: 
You can enable automatic syncing of the application with the following command: 
argocd app set <app-name> --sync-policy automated 
This ensures that any new changes in the Git repository are automatically 
deployed to your Kubernetes cluster without manual intervention. 
 
 
 
Step 9 DNS Mapping with GoDaddy Domain 
 
To map a load balancer domain with a GoDaddy domain, you'll need to follow 
these steps: 
 
1. Get the Load Balancer DNS Name 
• If you're using AWS, go to the EC2 Dashboard > Load Balancers. 
• Select your load balancer and find the DNS name under the Description tab. 
• Copy this DNS name as you'll need it when configuring your GoDaddy 
domain. 
2. Log In to GoDaddy 
• Go to the GoDaddy website and log in to your account. 
3. Access Domain Settings 
• Once logged in, go to the Domains section and select the domain name you 
want to map to your load balancer. 
• Click on the domain name to access its settings. 
4. Manage DNS Settings 
• Scroll down to the DNS Settings section. 
• Click on Manage DNS to open the DNS management page. 
5. Add a CNAME Record 
• In the DNS management page, under the Records section, click on Add to 
create a new DNS record. 
• Choose CNAME as the type of record. 
• In the Host field, enter the subdomain you want to use (e.g., www or app). 
• In the Points to field, paste the DNS name of your load balancer that you 
copied earlier. 
• Set the TTL (Time To Live) value (the default is usually fine). 
• Click Save to apply the changes. 
6. Update the A Record (Optional) 
• If you want to map the root domain (e.g., example.com), you may need to 
update the A Record. 
• Instead of a CNAME, add or modify the existing A Record to point to the IP 
address of your load balancer (if available) or use a service like AWS Route 
53 to map the root domain to the load balancer. 
7. Wait for DNS Propagation 
• DNS changes can take some time to propagate, usually within a few 
minutes to 24 hours. 
• You can use tools like What's My DNS to check if the changes have 
propagated globally. 
8. Test the Setup 
• Once DNS propagation is complete, you should be able to access your 
application using your GoDaddy domain name mapped to the load 
balancer.

