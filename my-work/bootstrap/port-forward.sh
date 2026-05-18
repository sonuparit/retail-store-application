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

prom_port_fwd() {

  echo ""
  log_info "don't forget to open the ports"

  echo ""
  echo "========================================="
  log_info " RUNNING PROMETHEUS PORT-FWD"
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
  log_info " RUNNING GRAFANA PORT-FWD"
  echo "========================================="
  
  kubectl port-forward svc/kube-prom-stack-grafana \
    3000:80 -n "${NAMESPACE}" \
    --address=0.0.0.0 \
    > /tmp/grafana-portforward.log 2>&1 &
}

grafana_passwd() {

  echo ""
  echo "========================================="
  log_info " GRAFANA PASSWORD..."
  echo "-----------------------------------------"

  GRAFANA_PASS=$(kubectl get secret -n "${NAMESPACE}" \
    kube-prom-stack-grafana -o \
    jsonpath='{.data.admin-password}' \
    | base64 -d && echo)
    
  log_info "access grafana at: http://${PUBLIC_IP}:3000"
  log_info "grafana password : $GRAFANA_PASS"
  echo "-----------------------------------------"

}

alert_mngr_port_fwd() {

  echo ""
  echo "========================================="
  log_info " STARTING ALERTMANAGER PORT FORWARD..."
  echo "========================================="

  kubectl port-forward \
    -n "${NAMESPACE}" \
    svc/kube-prom-stack-alertmanager \
    9093:9093 --address=0.0.0.0 \
    > /tmp/alertmanager-portforward.log 2>&1 &

  log_info "access alertmanager at: http://${PUBLIC_IP}:9093"
}

loki_port_fwd() {

  echo ""
  echo "========================================="
  log_info " STARTING LOKI PORT FORWARD..."
  echo "========================================="

  kubectl port-forward \
    -n "${NAMESPACE}" \
    svc/loki 3100:3100 \
    --address=0.0.0.0 \
    > /tmp/loki-portforward.log 2>&1 &

  log_info "access loki at: http://${PUBLIC_IP}:3100"
}

app_port_fwd() {

  echo ""
  echo "========================================="
  log_info " RUNNING APP PORT-FWD"
  echo "========================================="
  
  kubectl port-forward svc/kube-prom-stack-kube-prome-prometheus \
    8080:8080 -n dev \
    --address=0.0.0.0 \
    > /tmp/app-portforward.log 2>&1 &

  log_info "access app at: http://${PUBLIC_IP}:8080"

}

port_forwarding_main() {

  echo ""
  log_info "don't forget to open the ports"
  
  echo ""
  echo "========================================="
  log_info " RUNNING PORT FORWARD"
  echo "========================================="

  prom_port_fwd
  
  grafana_port_fwd
  
  grafana_passwd
  
  alert_mngr_port_fwd
  
  loki_port_fwd
  
  app_port_fwd
  
  echo ""
  echo "========================================="
  log_info " PORT FORWARD COMPLETED SUCCESSFULLY"
  echo "========================================="

}

port_forwarding_main