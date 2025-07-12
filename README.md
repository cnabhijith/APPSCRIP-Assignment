# install Jenkins on VM

'''bash
 sudo apt install openjdk-17-jre-headless 

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
sudo systemctl enable jenkins
sudo systemctl start Jenkins


### 📌 1. Install Terraform

sudo snap install terraform --classic

### 📌 2. Install AWS CLI

Download and install AWS CLI on the VM:

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

sudo apt install unzip

unzip awscliv2.zip

sudo ./aws/install

aws configure


### 📌 3. Install Kubectl

Install kubectl:

curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-0105/bin/linux/amd64/kubectl

chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin

kubectl version --short --client


### 📌 4. Install EKSCTL

Install eksctl for EKS cluster management:

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin

eksctl version
 
### 📌 Create Terraform Files

Create the following files for your Terraform setup:

backend.tf

data.tf

main.tf

outputs.tf

provider.tf

terraform.tfvars

variables.tf


### 📌 7. Run Terraform Commands

Initialize and apply Terraform configurations:

terraform init

terraform plan

terraform apply -auto-approve

