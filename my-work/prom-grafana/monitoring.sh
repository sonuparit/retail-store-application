#!/bin/bash

set -euo pipefail

PUBLIC_IP=$(curl -s ifconfig.me)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NAMESPACE="monitoring"

create_namespace() {

  echo "========================================="
  echo " CREATING NAMESPACE"
  echo "========================================="

  kubectl apply -f "${SCRIPT_DIR}/monitoring/namespace.yaml"

  sleep 3

  echo ""
}

add_helm_repos() {

  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/

  echo ""
  helm repo update
  
}

install_metrics_server() {

  echo ""
  echo "========================================="
  echo "INSTALLING METRICS SERVER"
  echo "========================================="

  helm upgrade --install metrics-server metrics-server/metrics-server \
    -n kube-system \
    -f "${SCRIPT_DIR}/monitoring/metrics-server.yaml"
    
  sleep 3
  
}

install_kube_prom() {

  echo ""
  echo "========================================="
  echo " INSTALLING kube-prometheus-stack"
  echo "========================================="

  helm upgrade --install kube-prom-stack prometheus-community/kube-prometheus-stack \
    -n "${NAMESPACE}" \
    -f "${SCRIPT_DIR}/monitoring/values-monitoring.yaml"
    
  sleep 3

}

wait_for_stack() {

  echo ""
  echo "========================================="
  echo " WAITING FOR MONITORING STACK PODS max 5 mins"
  echo "========================================="

  kubectl wait --for=condition=Ready pod \
    --all \
    -n "${NAMESPACE}" \
    --timeout=300s
  
}

#install_service_monitor() {
#
#  echo ""
#  echo "========================================="
#  echo " APPLYING SERVICE-MONITORS"
#  echo "========================================="#
#
#  kubectl apply -f "${SCRIPT_DIR}/service-monitors/argocd.yaml"
#  #  -n "${NAMESPACE}" not required already present in yaml file#
#
#}

prom_port_fwd() {

  echo ""
  echo "========================================="
  echo " RUNNING PROMETHEUS PORT-FWD"
  echo "========================================="
  
  kubectl port-forward svc/kube-prom-stack-kube-prome-prometheus \
    9090:9090 -n "${NAMESPACE}" \
    --address=0.0.0.0 \
    > /tmp/prometheus-portforward.log 2>&1 &
  

  echo "access prometheus at: http://${PUBLIC_IP}:9090"

}

grafana_port_fwd() {

  echo ""
  echo "========================================="
  echo " RUNNING GRAFANA PORT-FWD"
  echo "========================================="
  
  kubectl port-forward svc/kube-prom-stack-grafana \
    3000:80 -n "${NAMESPACE}" \
    --address=0.0.0.0 \
    > /tmp/grafana-portforward.log 2>&1 &
    
    # > /dev/null 2>&1 &

  echo "access grafana at: http://${PUBLIC_IP}:3000"

}

grafana_passwd() {

  GRAFANA_PASS=$(kubectl get secret -n "${NAMESPACE}" \
    kube-prom-stack-grafana -o \
    jsonpath='{.data.admin-password}' \
    | base64 -d && echo)
  
  echo "grafana password: $GRAFANA_PASS"

}

install_postgre_exporter() {

  echo ""
  echo "========================================="
  echo " CREATING POSTGRESQL EXPORTER"
  echo "========================================="
  
  kubectl apply -f "${SCRIPT_DIR}/postgresql/"

}

monitoring() {

  create_namespace
  
  add_helm_repos
  
  install_metrics_server
  
  install_kube_prom
  
  wait_for_stack
  
#  install_service_monitor
  
  prom_port_fwd
  
  grafana_port_fwd
  
  grafana_passwd
  
#  install_postgre_exporter
  
  echo ""
  echo "========================================="
  echo " Monitoring stack installed successfully"
  echo "========================================="

}

monitoring