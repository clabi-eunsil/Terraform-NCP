# bastion 환경 설정
## kubectl 설치
```sh
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl
```
### kubectl 설치 확인
```sh
kubectl version --client
```
## ncp-iam-authenticator 설치
```sh
curl -o ncp-iam-authenticator -L https://github.com/NaverCloudPlatform/ncp-iam-authenticator/releases/latest/download/ncp-iam-authenticator_linux_amd64
chmod +x ./ncp-iam-authenticator
mkdir -p $HOME/bin && cp ./ncp-iam-authenticator $HOME/bin/ncp-iam-authenticator && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bash_profile
```
### ncp-iam-authenticator 설치 확인
```sh
ncp-iam-authenticator help
```
## iam 인증 설정
```
mkdir .ncloud
vi ~/.ncloud/configure
```
### configure 내용  
**민간 NCP**
```sh
[DEFAULT]
ncloud_access_key_id = <>
ncloud_secret_access_key = <>
ncloud_api_url = https://ncloud.apigw.ntruss.com

[project]
ncloud_access_key_id = <>
ncloud_secret_access_key = <>
ncloud_api_url = https://ncloud.apigw.ntruss.com
```
**공공 NCP**
```sh
[DEFAULT]
ncloud_access_key_id = <>
ncloud_secret_access_key = <>
ncloud_api_url = https://ncloud.apigw.gov-ntruss.com

[project]
ncloud_access_key_id = <>
ncloud_secret_access_key = <>
ncloud_api_url = https://ncloud.apigw.gov-ntruss.com
``` 

### kubeconfig.yaml 생성
```sh
ncp-iam-authenticator create-kubeconfig --region KR --clusterUuid <cluster-uuid> --output kubeconfig.yaml
```

### 설정 확인
```sh
kubectl get namespaces --kubeconfig kubeconfig.yaml
```

### 명령어 단축
- `--kubeconfig` 옵션을 매번 사용하기 번거롭기때문에 `.kube/config`에 NKS 정보를 복사
```sh
cp kubeconfig.yaml .kube/config
```

---  
---  

# ArgoCD 환경 설정
## argocd 설치
```sh
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### argocd 설치 확인
```sh
kubectl get all -n argocd
```

## ingress 설정
- argocd를 더욱 편하게 사용하기 위해서는 DNS로 접근이 가능해야 한다.
- NCP의 alb를 통해 접근할 수 있도록 ingress 설정을 해주자.

### service를  `node port`로 변경
```sh
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
```

### tls 해제
- ALB에 `cert`를 추가해주면, k8s 내부에서 tls로 통신할 필요가 없으므로 해당 설정을 해제해주자.

```sh
kubectl edit cm argocd-cmd-params-cm -n argocd
```
- editor에서 ## 부분을 추가해주자.
```sh
apiVersion: v1
data:				          ## 해당 부분 추가
  server.insecure: "true"     ## 해당 부분 추가
kind: ConfigMap
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"ConfigMap","metadata":{"annotations":{},"labels":{"app.kubernetes.io/name":"argocd-cmd-params-cm","app.kubernetes.io/part-of":"argocd"},"name":"argocd-cmd-params-cm","namespace":"argocd"}}
... 중략 ...
```

### yaml file 생성
```sh
vi argocd-ingress.yaml
```
- 아래 내용으로 yaml 파일을 채워주자.
- `<cert no>` 와 `<domain>` 부분을 변경해주어야 한다.
    - 해당 작업 이전에 `콘솔 > Certificate Manager` 에서 **인증서 등록**을 먼저 해주어야 한다.
```sh
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80},{"HTTPS":443}]'
    alb.ingress.kubernetes.io/ssl-certificate-no: "<cert no>" 
    alb.ingress.kubernetes.io/actions.ssl-redirect: |
      {"type":"redirection","redirection":{"port": "443","protocol":"HTTPS","statusCode":301}}
  labels:
    app: argocd-alb-ingress
  name: argocd-alb-ingress
  namespace: argocd
spec:
  ingressClassName: alb
  defaultBackend:
    service:
      name: argocd-server
      port:
        number: 80
  rules:
  - host: <domain>
    http:
      paths:
      - path: /*
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 80
```

### ingress 배포
- 아래 명령어를 통해 ingress를 배포하면, 콘솔에서 alb가 생성되는 것을 확인할 수 있다.
- 콘솔에서 alb 생성이 완료되면 해당 alb 접속 정보를 통해서도 argocd에 접근이 가능한 것을 확인할 수 있다.
```sh
kubectl apply -f argocd-ingress.yaml -n argocd
```
### 기존 pod 삭제
- ingress를 배포하기 전에 생성된 `argocd-server` 파드를 삭제 후, 새롭게 생성해주어야 domain의 backend로 argocd server가 붙게된다.
```sh
# argocd-server의 pod name 확인
kubectl get po -n argocd

# 현재 생성되어 있는 argocd-server 삭제
kubectl delete -n argocd po argocd-server-#### 
```

### 초기 비밀번호 확인
- argocd에 로그인하기 위한 비밀번호를 확인해보자.
- **username** : `admin` 
```sh
kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 비밀번호 변경
- 위에서 확인한 초기 비밀번호를 통해 argocd 웹에 접속하면 password 변경이 가능하다.
1. argocd 접속
2. 좌측의 `User Info` 클릭
3. 상단 `Update Password` 를 통해 신규 PW 등록
- *pod에 직접 접근하여 변경하는 방법도 있으나, 해당 방법이 더욱 편리하므로 pod 접근 방법의 설명은 생략함*


---  
---  

# Trouble Shooting
## 01. iam 인증 문제
### sub account  권한 추가
- NKS를 생성한 계정이 아닌, 다른 sub account로 NKS에 엑세스할 때에는 iam을 추가해주어야 한다.
1. 콘솔상에서  `NKS > Clusters > 액세스` 탭으로 이동
2. IAM 액세스 항목 하단의 `+ 생성하기` 클릭
3. `User`에 NKS에 엑세스할 sub account 선택 후 `다음` 으로 이동
4. `정책 추가`에서 `NKSClusterAdminPolicy` 추가 후 `다음 > 생성하기` 클릭
5. 엑세스 할 sub account의 `Access Key`로 `configure` 파일 생성

### 02. default name space 변경
- 계속해서 `-n argocd` 옵션을 사용해 네임스페이스를 확인하는 것이 번거롭다면 아래 옵션을 추가해주자.
```sh
kubectl config set-context --current --namespace argocd

kubectl config view --minify|grep namespace
``` 

### 03. kubectl 관련 alias 등록
- 여러개의 NKS를 하나의 bastion에서 관리하거나, `kubectl` 명령어를 더욱 쉽게 사용하기 위해서 `alias`를 등록해줄 수 있다.
```sh
# 예시
alias kctl='kubectl --kubeconfig=/home/<path>/kubeconfig.yaml'
```
- `.bashrc` 에 등록하여 부팅 시 자동 적용되도록 설정할 수도 있음
