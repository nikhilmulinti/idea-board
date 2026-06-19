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

### Option 1: Deploy on Google Cloud Platform (GCP)

#### Prerequisites
- GCP Account with billing enabled
- gcloud CLI installed and configured
- Terraform 1.3+ installed
- kubectl, Helm 3.10+, and Helmfile 0.150+ installed

#### Step 1: Provision GCP Infrastructure with Terraform

```bash
# 1. Clone the repository
git clone https://github.com/nikhilmulinti/idea-board.git
cd idea-board

# 2. Set up GCP authentication
gcloud auth application-default login
gcloud config set project reborg-studio-development

# 3. Create Terraform state bucket (one-time setup)
cd infra-as-code/terraform/remote-state/gcp
terraform init
terraform apply -auto-approve

# 4. Provision the infrastructure
cd ../../environments/gcp
terraform init
terraform plan
terraform apply

# 5. Get cluster credentials
gcloud container clusters get-credentials idea-board-dev \
  --region us-central1 \
  --project reborg-studio-development
```

#### Step 2: Deploy Application with Helmfile

```bash
# 1. Navigate to deployment directory
cd ../../../../deployment

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

### Option 2: Using Existing Kubernetes Cluster

#### Prerequisites
- Kubernetes cluster already running
- kubectl configured
- Helm 3.10+
- Helmfile 0.150+

#### Installation Steps

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

## 🏗️ Infrastructure as Code (Terraform)

### GCP Infrastructure Components

The Terraform configuration provisions the following resources on GCP:

- **GKE Cluster**: Managed Kubernetes with autoscaling (1-3 nodes)
- **Cloud SQL**: PostgreSQL instance for persistent data
- **VPC Network**: Custom network with private/public subnets
- **Service Accounts**: For workload identity and access control
- **Cloud Storage**: Optional S3-compatible bucket for backups

### Terraform Configuration Files

```
infra-as-code/terraform/
├── environments/gcp/
│   ├── main.tf              # Main infrastructure definition
│   ├── variables.tf         # Variable declarations
│   ├── terraform.tfvars     # Environment-specific values
│   └── modules/
│       ├── networking/      # VPC and subnet configuration
│       ├── db/             # Cloud SQL setup
│       └── kubernetes/     # GKE cluster configuration
└── remote-state/gcp/
    ├── main.tf             # State bucket configuration
    └── terraform.tfvars    # State bucket settings
```

### Customizing Infrastructure

Edit `infra-as-code/terraform/environments/gcp/terraform.tfvars`:

```hcl
# Cluster Configuration
project_id         = "your-gcp-project"
region            = "us-central1"
zone              = "us-central1-a"
node_machine_type = "e2-medium"    # Change for different performance
min_node_count    = 1               # Minimum cluster size
max_node_count    = 5               # Maximum for autoscaling

# Database Configuration
db_instance_tier  = "db-f1-micro"   # Use db-g1-small for production
db_disk_size_gb   = 10              # Increase for production
db_password       = "ChangeMeSecure123!"  # MUST change for production
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

## 🔧 Troubleshooting

### GCP/Terraform Common Issues

**Authentication Error:**
```bash
# If you see: "could not find default credentials"
gcloud auth application-default login

# Or use service account key
export GOOGLE_APPLICATION_CREDENTIALS="path/to/key.json"
```

**API Not Enabled:**
```bash
# Enable required APIs manually if needed
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable servicenetworking.googleapis.com
```

**Terraform State Issues:**
```bash
# If state is locked
terraform force-unlock <LOCK_ID>

# Refresh state
terraform refresh
```

**Cleanup Resources:**
```bash
# Destroy infrastructure (careful!)
cd infra-as-code/terraform/environments/gcp
terraform destroy

# Remove Helmfile deployments
cd deployment
helmfile -e dev destroy
```

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
