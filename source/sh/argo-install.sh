#!/bin/bash

###### 콘솔상에서의 인증서 등록 및 번호 확인, 
###### 사용할 argocd domain (ex> argo.test.clabi.co.kr) 을 미리 정해두어야 함 ######

read -p "Enter your Certificate Number: " CERT_NO
read -p "Enter your Domain: " DOMAIN

# ArgoCD 설치
echo "Installing ArgoCD..."
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# ArgoCD 서비스 설정 변경
echo "Configuring ArgoCD Service..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

# TLS 설정 해제
kubectl patch cm argocd-cmd-params-cm -n argocd --type merge -p '{"data":{"server.insecure":"true"}}'

# Ingress 설정 생성
echo "Creating Ingress for ArgoCD..."
cat <<EOF > argocd-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80},{"HTTPS":443}]'
    alb.ingress.kubernetes.io/ssl-certificate-no: "$CERT_NO"
    alb.ingress.kubernetes.io/actions.ssl-redirect: |
      {"type":"redirection","redirection":{"port": "443","protocol":"HTTPS","statusCode":301}}
  labels:
    app: argocd-alb-ingress
  name: argocd-alb-ingress
  namespace: argocd
spec:
  ingressClassName: alb
  rules:
  - host: $DOMAIN
    http:
      paths:
      - path: /*
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 80
EOF

# Ingress 배포
kubectl apply -f argocd-ingress.yaml -n argocd

# 기존 ArgoCD 서버 Pod 삭제
kubectl delete pod -l app.kubernetes.io/name=argocd-server -n argocd

# ArgoCD 초기 비밀번호 확인
echo "ArgoCD initial password:"
kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d