Challenges and Solution:

## Challenge: ArgoCD Namespace Permission Errors Across Platform Components

While implementing GitOps using ArgoCD, one major issue encountered was repeated deployment failures caused by AppProject namespace restrictions.

Example errors:

```text
namespace kube-system is not permitted in project 'observability'
namespace argocd is not permitted in project 'observability'
namespace loki is not permitted in project 'observability'
```

## Solution: Dedicated Platform and Observability AppProject Architecture

To solve this problem in a scalable and production-aligned way, a dedicated platform and Observability AppProject was introduced specifically for infrastructure and cluster-level services.

Instead of granting permissions incrementally, the architecture was redesigned around logical platform boundaries.