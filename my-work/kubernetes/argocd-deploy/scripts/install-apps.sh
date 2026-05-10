#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =========================================================
# 🚀 Kubernetes GitOps Bootstrap Script
# =========================================================
# Purpose:
# Recreate complete local platform automatically:
#
# - Install apps
#
# =========================================================

# -----------------------------
# CONFIG
# -----------------------------

PUBLIC_IP=$(curl -s ifconfig.me)

ROOT_APP_FILE="${SCRIPT_DIR}/../root-app.yaml"

APP_NAMESPACE="dev"

ARGO_NAMESPACE="argocd"

APP_SERVICE="ui-dev-service"

APP_LOCAL_PORT="8888"

APP_TARGET_PORT="8080"

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

# =========================================================
# APPLY ROOT APP
# =========================================================

apply_root_app() {

    log_info "Applying root ArgoCD application..."

    kubectl apply -f "$ROOT_APP_FILE" -n "$ARGO_NAMESPACE"

    echo ""
}

# =========================================================
# WAIT FOR APP
# =========================================================

wait_for_app() {

  log_info "Waiting for Application..."
  
  sleep 30
  
  kubectl wait \
    --for=condition=Available \
    deployment/orders-dev \
    -n dev \
    --timeout=300s
    
  echo ""
}

# =========================================================
# PORT FORWARD APPLICATION
# =========================================================

port_forward_app() {

    log_info "Starting application port-forward..."

    kubectl port-forward svc/${APP_SERVICE} \
      -n "$APP_NAMESPACE" \
      ${APP_LOCAL_PORT}:${APP_TARGET_PORT} \
      --address=0.0.0.0 \
      > /dev/null 2>&1 &

    sleep 3

    log_info "Application available at http://${PUBLIC_IP}:$APP_LOCAL_PORT"
    echo ""
}

install_apps() {

  apply_root_app
  
  wait_for_app

  port_forward_app

}
  
install_apps