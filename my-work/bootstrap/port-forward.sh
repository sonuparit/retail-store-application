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

NAMESPACE="observability"

ARGO_NAMESPACE="argocd"

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

port_forward_argocd() {

  echo ""
  log_info "Starting ArgoCD port-forward..."

  kubectl port-forward svc/argocd-server \
    -n "${ARGO_NAMESPACE}" \
    8080:80 --address=0.0.0.0 \
    > /tmp/argocd-portforward.log 2>&1 &

  sleep 5
    
}

fetch_argocd_password() {

  echo ""
  log_info "Fetching ArgoCD admin password..."

  ARGO_PASSWORD=$(kubectl -n "${ARGO_NAMESPACE}" get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -d)

  echo ""
  echo "========================================="
  log_info " ArgoCD Login"
  echo "-----------------------------------------"
  echo " URL:      http://${PUBLIC_IP}:8080"
  echo " Username: admin"
  echo " Password: ${ARGO_PASSWORD}"
  echo "========================================="
  echo ""

}

prom_port_fwd() {

  echo ""
  echo "========================================="
  log_info " RUNNING PROMETHEUS PORT-FWD"
  echo "========================================="
  
  kubectl port-forward svc/prometheus-stack-kube-prom-prometheus \
    -n "${NAMESPACE}" 9090:9090 --address=0.0.0.0 \
    > /tmp/prometheus-portforward.log 2>&1 &

  log_info "access prometheus at: http://${PUBLIC_IP}:9090"
  
  sleep 5

}

grafana_port_fwd() {

  echo ""
  echo "========================================="
  log_info " RUNNING GRAFANA PORT-FWD"
  echo "========================================="
  
  kubectl port-forward svc/prometheus-stack-grafana \
    -n "${NAMESPACE}" 3000:80 --address=0.0.0.0 \
    > /tmp/grafana-portforward.log 2>&1 &
    
  sleep 5
}

grafana_passwd() {

  echo ""
  log_info "Fetching Grafana admin password..."
  
  GRAFANA_PASS=$(kubectl get secret prometheus-stack-grafana \
  -n "${NAMESPACE}" -o jsonpath='{.data.admin-password}' \
  | base64 -d && echo)

  echo ""
  echo "========================================="
  log_info " Grafana Login"
  echo "-----------------------------------------"
  echo " URL:      http://${PUBLIC_IP}:3000"
  echo " Username: admin"
  echo " Password: ${GRAFANA_PASS}"
  echo "========================================="
  echo ""

}

alert_mngr_port_fwd() {

  echo ""
  echo "========================================="
  log_info " STARTING ALERTMANAGER PORT FORWARD..."
  echo "========================================="

  kubectl port-forward svc/prometheus-stack-kube-prom-alertmanager \
    -n "${NAMESPACE}" 9093:9093 --address=0.0.0.0 \
    > /tmp/alertmanager-portforward.log 2>&1 &

  log_info "access alertmanager at: http://${PUBLIC_IP}:9093"
  
  sleep 5
}

app_port_fwd() {

  echo ""
  echo "========================================="
  log_info " RUNNING APP PORT-FWD"
  echo "========================================="
  
  kubectl port-forward svc/ui-dev-service \
    8080:8080 -n dev --address=0.0.0.0 \
    > /tmp/app-portforward.log 2>&1 &

  log_info "access app at: http://${PUBLIC_IP}:8080"
  
  sleep 5

}

port_forwarding_main() {

  pkill -f "kubectl port-forward" || true

  echo ""
  log_info "don't forget to open the ports"
  
  echo ""
  echo "========================================="
  log_info " RUNNING PORT FORWARD"
  echo "========================================="
  
  port_forward_argocd
  
  fetch_argocd_password

  prom_port_fwd
  
  grafana_port_fwd
  
  grafana_passwd
  
  alert_mngr_port_fwd
  
  app_port_fwd
  
  echo ""
  echo "========================================="
  log_info " PORT FORWARD COMPLETED SUCCESSFULLY"
  echo "========================================="
  echo ""

}

port_forwarding_main