# EKS Cluster Setup and ArgoCD Deployment with GoDaddy DNS Integration


###  8. Create EKS Cluster & Set Up ArgoCD on EKS

### Install ArgoCD CLI

First, install the ArgoCD CLI to interact with ArgoCD:

 Download ArgoCD CLI


sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argocd/releases/latest/download/argocd-linux-amd64


 Make it executable

sudo chmod +x /usr/local/bin/argocd


 Verify installation

argocd version

###  Install ArgoCD in the Kubernetes Cluster

 Create Namespace

kubectl create namespace argocd

 Install ArgoCD using official manifests

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argocd/stable/manifests/install.yaml

 Verify pods


kubectl get pods -n argocd


###  Expose the ArgoCD Server

Option 1: Port-Forwarding (Quick Setup)


kubectl port-forward svc/argocd-server -n argocd 8080:443

Access ArgoCD UI at: https://localhost:8080

###  Option 2: LoadBalancer (Public Access)

kubectl edit svc argocd-server -n argocd

Change:

type: ClusterIP

To:

type: LoadBalancer

Then retrieve external IP:

kubectl get svc argocd-server -n argocd

Access ArgoCD UI at: https://<EXTERNAL-IP>

###  4. Access ArgoCD Web UI

Login Info:

Username: admin

Password: 

kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d


###  5. Connect a GitHub Repository to ArgoCD

argocd app create <app-name> \

--repo <repository-url> \

--path <directory-in-repo> \

--dest-server https://kubernetes.default.svc \

--dest-namespace <k8s-namespace>

Then:

argocd app sync <app-name>

argocd app get <app-name>

###  6. Automate Syncing with GitOps

Enable auto-sync to keep your cluster in sync with your Git repository:

argocd app set <app-name> --sync-policy automated


###  Step 9: DNS Mapping with GoDaddy Domain

###  1. Get the Load Balancer DNS Name

Go to EC2 Dashboard → Load Balancers

Copy the DNS name under the Description tab

###  2. Log In to GoDaddy

Go to GoDaddy and log in.

###  3. Access Domain Settings

Go to the Domains section

Select the domain

Click to open domain settings

###  . Manage DNS Settings

Scroll to DNS Settings

Click Manage DNS

### . Add a CNAME Record

Type: CNAME

Host: www or app

Points to: DNS of Load Balancer

TTL: Default or as required

Click Save

###  6. Update the A Record (Optional)

To map the root domain (example.com):

Modify or add an A Record to point to the IP address of the Load Balancer

Or use AWS Route 53 for alias mapping

###  7. Wait for DNS Propagation

Changes may take a few minutes to 24 hours.


###  8. Test the Setup

After DNS is updated, your GoDaddy domain should route to the application on your EKS cluster.

###  DNS Resolution Verification (Output)

nslookup <domain>

