#!/bin/bash

groupadd sysadm
echo '%sysadm ALL=NOPASSWD:ALL' >> /etc/sudoers.d/sysadm
chmod 440 /etc/sudoers.d/sysadm
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/ClientAliveCountMax 0/ClientAliveCountMax 5/g' /etc/ssh/sshd_config
sed -i 's/APT::Periodic::Update-Package-Lists "1"/APT::Periodic::Update-Package-Lists "0"/' /etc/apt/apt.conf.d/10periodic
systemctl restart sshd
useradd -m -p $(openssl passwd -1 -salt uber Korea@1234) -g sysadm -s /bin/bash clabi

# Set environment variables
NCP_ACCESS_KEY="${ncp_access_key}"
NCP_SECRET_KEY="${ncp_secret_key}"
CLUSTER_UUID="${cluster_uuid}"
ENVIRONMENT="${environment}"

# Set ncloud_api_url
if [[ $ENVIRONMENT == "gov" ]]; then
  NCP_API_URL="https://ncloud.apigw.gov-ntruss.com"
else
  NCP_API_URL="https://ncloud.apigw.ntruss.com"
fi

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl

# Verify kubectl installation
kubectl version --client

# Install ncp-iam-authenticator
echo "Installing ncp-iam-authenticator..."
curl -o ncp-iam-authenticator -L https://github.com/NaverCloudPlatform/ncp-iam-authenticator/releases/latest/download/ncp-iam-authenticator_linux_amd64
chmod +x ./ncp-iam-authenticator
mkdir -p $HOME/bin && cp ./ncp-iam-authenticator $HOME/bin/ncp-iam-authenticator
export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bash_profile
source .bash_profile

# Verify ncp-iam-authenticator installation
ncp-iam-authenticator help

# Configure IAM authentication for NCP
echo "Configuring IAM authentication..."
mkdir -p ~/.ncloud
cat <<EOF > ~/.ncloud/configure
[DEFAULT]
ncloud_access_key_id = $NCP_ACCESS_KEY
ncloud_secret_access_key = $NCP_SECRET_KEY
ncloud_api_url = $NCP_API_URL

[project]
ncloud_access_key_id = $NCP_ACCESS_KEY
ncloud_secret_access_key = $NCP_SECRET_KEY
ncloud_api_url = $NCP_API_URL
EOF

# Create kubeconfig.yaml for Kubernetes cluster access
ncp-iam-authenticator create-kubeconfig --region KR --clusterUuid $CLUSTER_UUID --output kubeconfig.yaml

# Copy kubeconfig settings to ~/.kube/config for kubectl usage
mkdir -p ~/.kube
cp kubeconfig.yaml ~/.kube/config

# Install k9s (Kubernetes CLI tool)
echo "Installing k9s..."
K9S_URL="https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_Linux_amd64.tar.gz"
mkdir -p $HOME/tmp 
curl -L $K9S_URL -o $HOME/tmp/k9s_Linux_amd64.tar.gz 
tar -xzf $HOME/tmp/k9s_Linux_amd64.tar.gz -C $HOME/tmp 
mv $HOME/tmp/k9s $HOME/bin/
rm -rf $HOME/tmp 
echo "k9s installation complete!"

source ~/.bash_profile