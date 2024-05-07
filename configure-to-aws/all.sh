#!/bin/bash

#BEFORE CREATING CLUSTER NEED SETUP THE SAME REGION WITH AWS CONFIGURE
echo "-------------Creating cluster-------------"
eksctl create cluster --config-file=/Users/yura/Desktop/advit_terraform_lessons/k8s_course_hands_on/configure-to-aws/cluster/cluster-config.yaml
echo "-------------Creating cluster done-------------"

#Before creating storage need setup addon for aws and change aws region in aws configure
echo "-------------Setup storage addons-------------"
eksctl utils associate-iam-oidc-provider --region=us-east-2 --cluster=fleetman --approve
eksctl create iamserviceaccount --name ebs-csi-controller-sa --namespace kube-system --cluster=fleetman --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy --approve  --role-only  --role-name AmazonEKS_EBS_CSI_DriverRole
eksctl create addon --name aws-ebs-csi-driver --cluster fleetman --service-account-role-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/AmazonEKS_EBS_CSI_DriverRole --force
echo "-------------Setup storage addons done-------------"

echo "-------------Create resources-------------"
cd /Users/yura/Desktop/advit_terraform_lessons/k8s_course_hands_on/configure-to-aws
kubectl apply -f .
echo "-------------Create resources done-------------"

echo "-------------Create ELK stack-------------"
kubectl create namespace monitoring
cd /Users/yura/Desktop/advit_terraform_lessons/k8s_course_hands_on/configure-to-aws/elk
kubectl apply -f .
echo "-------------Create ELK stack done-------------"

echo "-------------Create Prometheus+Grafana stack-------------"
kubectl annotate secret alertmanager-monitoring-kube-prometheus-alertmanager -n monitoring kubectl.kubernetes.io/last-applied-configuration="$(kubectl get secret alertmanager-monitoring-kube-prometheus-alertmanager -n monitoring -o json | jq -c '.' )"
cd /Users/yura/Desktop/advit_terraform_lessons/k8s_course_hands_on/configure-to-aws/monitoring/prometheus+grafana_configs
kubectl apply -f .
echo "-------------Create Prometheus+Grafana stack done-------------"


echo "-------------Create new secret for alert manager in prometheus-------------"
cd /Users/yura/Desktop/advit_terraform_lessons/k8s_course_hands_on/configure-to-aws/monitoring/alerts_configs
kubectl delete secret alertmanager-monitoring-kube-prometheus-alertmanager -n monitoring
kubectl create secret generic --from-file=alertmanager.yaml alertmanager-monitoring-kube-prometheus-alertmanager -n monitoring
echo "-------------Create new secret for alert manager in prometheus done-------------"

#kubectl get secret alertmanager-monitoring-kube-prometheus-alertmanager -n monitoring -o yaml


#Then check logs for updating alertmanager file
echo "-------------Check logs form config-reloader-------------"
kubectl logs alertmanager-monitoring-kube-prometheus-alertmanager-0 -n monitoring -c config-reloader
echo "-------------Check logs form config-reloader done-------------"

echo "-------------Check logs form config-alertmanager-------------"
kubectl logs alertmanager-monitoring-kube-prometheus-alertmanager-0 -n monitoring -c alertmanager
echo "-------------Check logs form config-alertmanager done-------------"

echo "-------------Create ingress-------------"
kubectl apply -f /Users/yura/Desktop/test_git/k8s-position-tracking/configure-to-aws/ingress
echo "-------------Create ingress done-------------"



#Need add to worker nodes SG inbound rules to allow traffic on ports 31001,31002,31003,31004
# Credentials to grafana - login-admin password=prom-operator
