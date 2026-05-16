#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =======================================
# 🚀 Kubernetes GitOps Bootstrap Script
# =======================================
# Purpose:
# Recreate complete local platform automatically:
#
# - Bootstrap everything
#
# =======================================

# -----------------------------
# CONFIG
# -----------------------------

EBS_DEVICE="/dev/nvme1n1"

EBS_MOUNT_PATH="/mnt/postgre-data"

CLUSTER_NAME="retail"

KIND_CONFIG="../01-infrastructure/kind-cluster/kind-config.yaml"

PUBLIC_IP=$(curl -s ifconfig.me)

NAMESPACE_FILE="./argocd/namespace.yaml"

ARGO_NAMESPACE="argocd"

ARGO_RELEASE_NAME="argocd"

ARGO_HELM_REPO="https://argoproj.github.io/argo-helm"

ARGO_VALUES_FILE="./argocd/argocd-install-values.yaml"

PROJECT_FILE="./argocd/argocd-project.yaml"

ROOT_APP="./argocd/root-app.yaml"

ARGOCD_LOCAL_PORT="8080"

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

trap 'log_error "Script failed at line $LINENO"' ERR

# =======================================
# CHECK DEPENDENCIES
# =======================================

check_dependencies() {

  log_info "Checking required tools..."

  tools=("docker" "kubectl" "helm" "kind")

  for tool in "${tools[@]}"
  do
    if ! command -v "$tool" &> /dev/null
    then
      log_error "$tool is not installed."
      exit 1
    fi
  done

  log_info "All dependencies found."
}

# ======================================
# CHECK DOCKER
# ======================================

check_docker() {

  log_info "Checking Docker daemon..."

  if ! docker log_info > /dev/null 2>&1
  then
    log_error "Docker is not running."
    exit 1
  fi

  log_info "Docker is running."
}

# =======================================
# MOUNT EBS
# =======================================

mount_ebs() {

  log_info "Checking EBS mount..."

  if mountpoint -q "$EBS_MOUNT_PATH"
  then
      log_warn "EBS already mounted at $EBS_MOUNT_PATH"
  else

    sudo mkdir -p "$EBS_MOUNT_PATH"

    sudo mount "$EBS_DEVICE" "$EBS_MOUNT_PATH"

    log_info "EBS mounted successfully."
  fi
  echo ""
}

create_kind_cluster() {

  log_info "Checking if kind cluster exists..."

  if kind get clusters | grep -q "$CLUSTER_NAME"
  then
      log_warn "Kind cluster already exists."
  else

    log_info "Creating kind cluster..."

    kind create cluster \
        --name "$CLUSTER_NAME" \
        --config "$KIND_CONFIG"

    log_info "Kind cluster created."
    
    # no need to set context for kubectl
  fi
  
}

create_namespace() {

  echo ""
  log_info "Creating Namespace..."
  kubectl apply -f "${NAMESPACE_FILE}"
  
  log_info "Namespace created."

}

install_argocd() {

  echo ""
  log_info "Installing ArgoCD..."

  helm install "$ARGO_RELEASE_NAME" argo/argo-cd \
      -n "$ARGO_NAMESPACE" -f "$ARGO_VALUES_FILE" \
      --create-namespace

  log_info "ArgoCD installation completed."

}

wait_for_argocd() {

  echo ""
  log_info "Waiting for ArgoCD server..."

  kubectl wait \
      --for=condition=available \
      deployment/argocd-server \
      -n "$ARGO_NAMESPACE" \
      --timeout=300s

  log_info "ArgoCD is ready."
  
}

port_forward_argocd() {

  echo ""
  log_info "Starting ArgoCD port-forward..."

  kubectl port-forward svc/argocd-server \
    -n "$ARGO_NAMESPACE" \
    ${ARGOCD_LOCAL_PORT}:80 \
    --address=0.0.0.0 \
    > /dev/null 2>&1 &

  sleep 2
    
}

fetch_argocd_password() {

  echo ""
  log_info "Fetching ArgoCD admin password..."

  ARGO_PASSWORD=$(kubectl -n "${ARGO_NAMESPACE}" get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -d)

  echo ""
  echo "========================================="
  echo " ArgoCD Login"
  echo "-----------------------------------------"
  echo " URL:      http://${PUBLIC_IP}:${ARGOCD_LOCAL_PORT}"
  echo " Username: admin"
  echo " Password: ${ARGO_PASSWORD}"
  echo "========================================="
  echo ""

}

create_project() {

  echo ""
  log_info "Creating ArgoCD project..."

  kubectl apply -f "${PROJECT_FILE}" -n "${ARGO_NAMESPACE}"
  
}

install_root_app() {

  echo ""
  log_info "Applying root-app..."

  kubectl apply -f "${ROOT_APP}" -n "${ARGO_NAMESPACE}"

}

# =====================================
# MAIN
# =====================================

main() {

  pkill -f "kubectl port-forward" || true

  # check_dependencies

  # check_docker
  
  echo ""
  
  log_info "Bootstrap started.. 🚀"

  mount_ebs

  create_kind_cluster
  
  # create_namespace

  install_argocd
  
  wait_for_argocd
  
  port_forward_argocd
  
  fetch_argocd_password
  
  create_project
  
  install_root_app

  log_info "Bootstrap completed successfully 🚀"
  
  echo ""
}

main