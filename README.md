# Idea Board Application

A simple full-stack application for sharing and managing ideas, built with React, FastAPI, and PostgreSQL.

## Architecture

- **Frontend**: React application with modern UI for displaying and submitting ideas
- **Backend**: FastAPI REST API with endpoints for managing ideas
- **Database**: PostgreSQL database for persistent storage

## Prerequisites

- Docker and Docker Compose installed on your machine
- Node.js 18+ (for local development without Docker)
- Python 3.11+ (for local development without Docker)

## Quick Start with Docker Compose

### 1. Clone the repository
```bash
git clone <repository-url>
cd idea-board
```

### 2. Build and run the containers
```bash
docker-compose up --build
```

This command will:
- Build the React frontend container
- Build the FastAPI backend container
- Start a PostgreSQL database container
- Set up networking between all services
- Initialize the database with sample data

### 3. Access the application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **Database**: localhost:5432 (postgres/postgres)

## Docker Compose Services

### Frontend Service
- Builds from `./frontend/Dockerfile`
- Runs on port 3000
- Configured to connect to backend at http://localhost:8000

### Backend Service
- Builds from `./backend/Dockerfile`
- Runs on port 8000
- Connects to PostgreSQL database
- Waits for database to be healthy before starting

### Database Service
- Uses PostgreSQL 15 Alpine image
- Runs on port 5432
- Persists data using Docker volume
- Includes health checks for proper startup sequencing

## Environment Variables

Copy `.env.example` to `.env` and adjust values as needed:

```bash
cp .env.example .env
```

## Development Commands

### Start all services
```bash
docker-compose up
```

### Start services in background
```bash
docker-compose up -d
```

### View logs
```bash
docker-compose logs -f [service-name]
```

### Stop all services
```bash
docker-compose down
```

### Stop and remove volumes (clean slate)
```bash
docker-compose down -v
```

### Rebuild containers
```bash
docker-compose build
```

### Access container shell
```bash
docker-compose exec backend sh
docker-compose exec frontend sh
docker-compose exec database psql -U postgres -d ideaboard
```

## API Endpoints

- `GET /api/ideas` - Retrieve all ideas
- `POST /api/ideas` - Create a new idea
  - Body: `{"content": "Your idea here"}`
- `GET /health` - Health check endpoint

## Project Structure

```
idea-board/
├── frontend/               # React frontend application
│   ├── src/               # Source code
│   ├── public/            # Static files
│   ├── package.json       # Dependencies
│   ├── Dockerfile         # Frontend container definition
│   └── nginx.conf         # Nginx configuration for production
├── backend/               # FastAPI backend application
│   ├── main.py           # API implementation
│   ├── requirements.txt  # Python dependencies
│   └── Dockerfile        # Backend container definition
├── database/             # Database configuration
│   └── init.sql         # Initial database setup
├── docker-compose.yml    # Multi-container orchestration
├── .env.example         # Environment variables template
└── README.md           # This file
```

## Troubleshooting

### Port already in use
If you get an error about ports being in use, you can change the port mappings in `docker-compose.yml`:
```yaml
ports:
  - "3001:80"  # Change 3001 to any available port
```

### Database connection issues
Ensure the database service is healthy:
```bash
docker-compose ps
docker-compose logs database
```

### Frontend can't connect to backend
Check that the `REACT_APP_API_URL` environment variable is set correctly and that the backend service is running.

## Next Steps

This application is ready for:
1. Containerization ✅
2. Deployment to cloud platforms (AWS, GCP, Azure)
3. Integration with CI/CD pipelines
4. Infrastructure as Code (Terraform/Pulumi)
5. AI-powered automation features
