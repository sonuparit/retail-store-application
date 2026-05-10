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

APP_LOCAL_PORT=8888

APP_TARGET_PORT=8080

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

detect_namespaces() {

  log_info "Waiting for application namespaces..."
  
  sleep 15

  local retries=40
  local count=0

  while true
  do

    ENVIRONMENTS=$(kubectl get ns -o jsonpath='{.items[*].metadata.name}' \
      | tr ' ' '\n' \
      | grep -E '^(dev|stage|prod)$' || true)

    if [ -n "$ENVIRONMENTS" ]
    then
      break
    fi

    sleep 5

    count=$((count + 1))

    if [ "$count" -ge "$retries" ]
    then
      log_error "No application namespaces detected."
      exit 1
    fi

  done

  log_info "Namespaces detected:"
  echo "$ENVIRONMENTS"
  echo ""
}

# =========================================================
# WAIT FOR APP
# =========================================================

wait_for_app() {

  for ENV in $ENVIRONMENTS
  do

    log_info "Waiting for deployments in ${ENV}"

    until kubectl get deployment -n "$ENV" | grep -q .
    do
      sleep 5
    done

    kubectl wait \
      --for=condition=Available \
      deployment \
      --all \
      -n "$ENV" \
      --timeout=300s

  done

  echo ""
}

# =========================================================
# PORT FORWARD APPLICATION
# =========================================================

port_forward_app() {

    log_info "Starting application port-forward..."
    
    INDEX=0

    for ENV in $ENVIRONMENTS
    do

      SERVICE="ui-${ENV}-service"

      PORT=$((APP_LOCAL_PORT + INDEX))

      kubectl port-forward \
        svc/${SERVICE} \
        -n "$ENV" \
        ${PORT}:${APP_TARGET_PORT} \
        --address=0.0.0.0 \
        > /dev/null 2>&1 &

      INDEX=$((INDEX + 1))
      
      log_info "Application available at http://${PUBLIC_IP}:$PORT"
      echo ""

    done
}

install_apps() {

  apply_root_app
  
  detect_namespaces
  
  wait_for_app

  port_forward_app

}
  
install_apps