#!/bin/bash

###### ZEN 을 사용할 경우, ingress controller 설치를 위해 74,75번 line의 주석 해제 필요 ######

###### Access Key, Cluster UUID 먼저 확인 필요 ######

# 사용자 입력 받기
read -p "Enter your Ncloud Access Key ID: " NCP_ACCESS_KEY_ID
read -p "Enter your Ncloud Secret Access Key: " NCP_SECRET_ACCESS_KEY
read -p "Enter your Cluster UUID: " CLUSTER_UUID

# 공공(private)/민간(public) 선택
echo "Is this a public or private environment? Enter 'public' or 'private': "
read ENVIRONMENT

# ncloud_api_url 설정
if [[ $ENVIRONMENT == "private" ]]; then
  NCP_API_URL="https://ncloud.apigw.gov-ntruss.com"
else
  NCP_API_URL="https://ncloud.apigw.ntruss.com"
fi

# kubectl 설치
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl

# kubectl 설치 확인
kubectl version --client

# ncp-iam-authenticator 설치
echo "Installing ncp-iam-authenticator..."
curl -o ncp-iam-authenticator -L https://github.com/NaverCloudPlatform/ncp-iam-authenticator/releases/latest/download/ncp-iam-authenticator_linux_amd64
chmod +x ./ncp-iam-authenticator
mkdir -p $HOME/bin && cp ./ncp-iam-authenticator $HOME/bin/ncp-iam-authenticator
export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bash_profile
source .bash_profile

# ncp-iam-authenticator 설치 확인
ncp-iam-authenticator help

# NCP IAM 인증 설정
echo "Configuring IAM authentication..."
mkdir -p ~/.ncloud
cat <<EOF > ~/.ncloud/configure
[DEFAULT]
ncloud_access_key_id = $NCP_ACCESS_KEY_ID
ncloud_secret_access_key = $NCP_SECRET_ACCESS_KEY
ncloud_api_url = $NCP_API_URL

[project]
ncloud_access_key_id = $NCP_ACCESS_KEY_ID
ncloud_secret_access_key = $NCP_SECRET_ACCESS_KEY
ncloud_api_url = $NCP_API_URL
EOF

# kubeconfig.yaml 생성
ncp-iam-authenticator create-kubeconfig --region KR --clusterUuid $CLUSTER_UUID --output kubeconfig.yaml

# kubeconfig 설정 복사
mkdir -p ~/.kube
cp kubeconfig.yaml ~/.kube/config

# k9s 설치
echo "Installing k9s..."
K9S_URL="https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_Linux_amd64.tar.gz"
mkdir -p $HOME/tmp 
curl -L $K9S_URL -o $HOME/tmp/k9s_Linux_amd64.tar.gz
tar -xzf $HOME/tmp/k9s_Linux_amd64.tar.gz -C $HOME/tmp
mv $HOME/tmp/k9s $HOME/bin/
rm -rf $HOME/tmp
echo "k9s installation complete!"

##### for ZEN hypervisor
# ALB Ingress Controller 설치
## echo "Installing ALB Ingress Controller..."
## kubectl apply -f https://raw.githubusercontent.com/NaverCloudPlatform/nks-alb-ingress-controller/main/docs/install/pub/install.yaml
#####