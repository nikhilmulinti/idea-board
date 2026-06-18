# Idea Board Application

A cloud-native, GitOps-enabled application for sharing and managing ideas, featuring automated CI/CD, multi-cloud support, and comprehensive DevOps practices.

## 🏗️ Architecture Overview

### Application Architecture
```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│   Frontend  │────▶│   Backend    │────▶│  PostgreSQL  │
│   (React)   │     │  (FastAPI)   │     │   Database   │
└─────────────┘     └──────────────┘     └──────────────┘
       │                    │                     │
       └────────────┬───────┴─────────────────────┘
                    │
              Kubernetes Cluster
                    │
       ┌────────────┼────────────┐
       │            │            │
   Ingress      ArgoCD      Image Updater
```

### GitOps Architecture
- **GitHub**: Source code repository with GitHub Actions CI/CD
- **Container Registry**: GitHub Container Registry (ghcr.io)
- **ArgoCD**: GitOps continuous deployment
- **ArgoCD Image Updater**: Automated image updates
- **Helmfile**: Declarative cluster management
- **Kubernetes**: Container orchestration platform

## 🚀 Quick Start - Local Development

### Prerequisites
- Docker and Docker Compose
- Node.js 18+ (optional for local development)
- Python 3.11+ (optional for local development)

### Running with Docker Compose

```bash
# Clone the repository
git clone https://github.com/nikhilmulinti/idea-board.git
cd idea-board

# Start all services
docker-compose up --build

# Access the application
# Frontend: http://localhost:3000
# Backend API: http://localhost:8000
# API Docs: http://localhost:8000/docs
```

## ☁️ Cloud Deployment

### Prerequisites
- Kubernetes cluster (AKS, EKS, or GKE)
- kubectl configured
- Helm 3.10+
- Helmfile 0.150+

### Installation Steps

```bash
# 1. Clone the repository
git clone https://github.com/nikhilmulinti/idea-board.git
cd idea-board/deployment

# 2. Configure your environment
cp environments/dev.yaml.example environments/dev.yaml
# Edit environments/dev.yaml with your values

# 3. Deploy everything with Helmfile
helmfile -e dev sync

# 4. Get the LoadBalancer IP
kubectl get svc -n ingress-nginx ingress-nginx-controller \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# 5. Configure DNS to point to the LoadBalancer IP

# 6. Access ArgoCD UI
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

### Deployment Structure
```
deployment/
├── helmfile.d/           # Helmfile configurations
│   ├── 01-infrastructure.yaml.gotmpl
│   ├── 02-argocd.yaml.gotmpl
│   └── 03-applications.yaml.gotmpl
├── charts/              # Helm charts
│   ├── backend/
│   ├── frontend/
│   └── argocd-app/
├── environments/        # Environment configurations
└── docs/               # Detailed documentation
```


## 🌍 Cloud-Agnostic Design

### Multi-Cloud Support
The application can be deployed on any Kubernetes cluster:

#### Azure AKS
```yaml
ingress:
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path: /healthz
```

#### AWS EKS
```yaml
ingress:
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
```

#### Google GKE
```yaml
ingress:
  annotations:
    cloud.google.com/load-balancer-type: External
```

### Portable Components
- **Containerized applications**: Docker images work anywhere
- **Helm charts**: Standardized Kubernetes deployments
- **External database support**: Can use managed databases (RDS, Cloud SQL, Azure Database)
- **Storage abstraction**: Supports various storage backends

## 📦 Technology Stack

### Frontend
- React 18 with Hooks
- Axios for API calls
- Docker multi-stage builds
- Runtime environment configuration

### Backend
- FastAPI with async support
- SQLAlchemy ORM
- PostgreSQL database
- Automatic API documentation

### DevOps & Infrastructure
- **Container Orchestration**: Kubernetes
- **Package Management**: Helm
- **GitOps**: ArgoCD
- **CI/CD**: GitHub Actions
- **Infrastructure as Code**: Helmfile
- **Ingress**: NGINX Ingress Controller
- **SSL/TLS**: cert-manager with Let's Encrypt
- **Container Registry**: GitHub Container Registry

## 🔧 Configuration

### Environment Variables

#### Frontend
```javascript
REACT_APP_API_URL=https://your-domain.com/api
```

#### Backend
```python
DATABASE_URL=postgresql://user:password@host:5432/dbname
CORS_ORIGINS=["https://your-domain.com"]
```

### Kubernetes Configuration
See `deployment/environments/dev.yaml` for full configuration options:
- Domain configuration
- Database credentials
- Resource limits
- Replica counts
- Ingress settings

## 📈 Monitoring & Observability

### Health Checks
- Frontend: `/` endpoint
- Backend: `/health` endpoint
- Kubernetes: Liveness and readiness probes

### Metrics
- Application metrics exposed via `/metrics`
- Kubernetes metrics via metrics-server
- Resource usage monitoring

## 🔐 Security

### Best Practices Implemented
- Secrets management via Kubernetes Secrets
- SSL/TLS encryption with cert-manager
- Network policies for pod communication
- Security contexts and non-root containers
- Regular automated image updates

## 🧪 Testing

```bash
# Backend tests
cd backend
pytest

# Frontend tests
cd frontend
npm test

# End-to-end tests
docker-compose -f docker-compose.test.yml up
```

## 📚 Documentation

- [Complete Installation Guide](deployment/docs/INSTALLATION.md)
- [API Documentation](http://localhost:8000/docs) (when running)
- [Troubleshooting Guide](deployment/docs/INSTALLATION.md#troubleshooting)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

- Built with modern cloud-native technologies
- Implements GitOps best practices
- Designed for production workloads
- Optimized for developer experience
