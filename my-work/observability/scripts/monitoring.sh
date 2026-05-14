#!/bin/bash

set -euo pipefail

# =======================================
# 🚀 Kubernetes monitoring Bootstrap Script
# =======================================
# Purpose:
# Recreate complete local platform automatically:
#
# - monitoring stack
#
# =======================================

# -----------------------------
# CONFIG
# -----------------------------

PUBLIC_IP=$(curl -s ifconfig.me)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NAMESPACE="monitoring"

# -----------------------------
# COLORS
# -----------------------------

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# -----------------------------
# LOGGING HELPERS
# -----------------------------

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

create_namespace() {

  echo "========================================="
  echo " CREATING NAMESPACE"
  echo "========================================="

  kubectl apply -f "${SCRIPT_DIR}/../stacks/kube-state-metrics/namespace.yaml"

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
    -f "${SCRIPT_DIR}/../stacks/kube-state-metrics/metrics-server.yaml"
  
}

install_kube_prom() {

  echo ""
  echo "========================================="
  echo " INSTALLING kube-prometheus-stack"
  echo "========================================="

  helm upgrade --install kube-prom-stack prometheus-community/kube-prometheus-stack \
    -n "${NAMESPACE}" \
    -f "${SCRIPT_DIR}/../stacks/prometheus-stack/prom-grafana-values.yaml"

}

wait_for_stack() {

  echo ""
  echo "========================================="
  echo " WAITING FOR MONITORING STACK PODS"
  echo "========================================="

  kubectl wait --for=condition=Ready pod \
    --all \
    -n "${NAMESPACE}" \
    --timeout=300s
  
}

prom_port_fwd() {

  echo ""
  log_info "don't forget to open the ports"

  echo ""
  echo "========================================="
  echo " RUNNING PROMETHEUS PORT-FWD"
  echo "========================================="
  
  kubectl port-forward svc/kube-prom-stack-kube-prome-prometheus \
    9090:9090 -n "${NAMESPACE}" \
    --address=0.0.0.0 \
    > /tmp/prometheus-portforward.log 2>&1 &
  

  log_info "access prometheus at: http://${PUBLIC_IP}:9090"

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
    
  log_info "access grafana at: http://${PUBLIC_IP}:3000"

}

grafana_passwd() {

  GRAFANA_PASS=$(kubectl get secret -n "${NAMESPACE}" \
    kube-prom-stack-grafana -o \
    jsonpath='{.data.admin-password}' \
    | base64 -d && echo)
  
  log_info "grafana password: $GRAFANA_PASS"

}

install_loki() {

  echo ""
  log_info "INSTALLING LOKI"
  
  helm repo add grafana https://grafana.github.io/helm-charts
  helm install loki grafana/loki \
  -n "${NAMESPACE}" \
  -f "${SCRIPT_DIR}/../stacks/loki/loki-values.yaml"

}

increase_inotify_limit() {

  echo ""
  log_info "INCREASING INOTIFY LIMIT TO 10000"
  
  fs.inotify.max_user_instances=10000
  fs.inotify.max_user_watches=1048576

}

install_promtail() {

  echo ""
  log_info "INSTALLING PROMTAIL"
  
  helm install promtail grafana/promtail \
  -n "${NAMESPACE}" \
  -f "${SCRIPT_DIR}/../stacks/loki/promtail-values.yaml"

}

monitoring() {

  create_namespace
  
  add_helm_repos
  
  install_metrics_server
  
  install_kube_prom
  
  wait_for_stack
  
  prom_port_fwd
  
  grafana_port_fwd
  
  grafana_passwd
  
  install_loki
  
  increase_inotify_limit
  
  install_promtail
  
  echo ""
  echo "========================================="
  echo " Monitoring stack installed successfully"
  echo "========================================="

}

monitoring