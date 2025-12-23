   Axy DevOps Engineer Assignment Solution
  
* Project Overview
This project demonstrates a complete three-tier microservices application with:

Part 1: Local development using Docker Compose

Part 2: Production deployment on AWS using Infrastructure as Code

I built this solution from scratch, focusing on security, scalability, and best practices.

1. What's Inside
2. Application Components
Frontend: HTML + JavaScript served via Nginx

Backend: Node.js + Express REST API

Database: PostgreSQL with persistent storage

* Infrastructure
Local: Docker Compose with private networking

Production: AWS with EC2 Auto Scaling, RDS, and Load Balancer

 Part 1: Local Development (Docker Compose)

bash
# 1. Clone and navigate
git clone <repository-url>
cd axy-devops-assignment

# 2. Run everything
docker-compose up --build

# 3. Open browser: http://localhost:8080
-> What You'll See
Frontend webpage showing "Axy DevOps Assignment"

Real-time backend health status

Interactive "Get Message" button fetching data from PostgreSQL

All services running in isolated containers

 Architecture (Local)
text
Your Browser → Frontend (Nginx:8080) → Backend (Node.js:3000) → Database (PostgreSQL:5432)

* Security Features
  
-> Only frontend exposed (port 8080)

-> Backend/database in private Docker network

-> Database not accessible from host

-> Environment variables for sensitive data

-> Health checks for all services

 Part 2: AWS Production Infrastructure
 
* Production Architecture
text
Internet Users
       ↓
[ Application Load Balancer ] ← HTTPS/HTTP, Health Checks
       ↓
[ Auto Scaling Group ] ← 2-4 EC2 instances (scales automatically)
       ↓
[ EC2 Instances (t3.small) ] ← Runs Docker containers with our app
       ↓
[ RDS PostgreSQL ] ← Multi-AZ, encrypted, daily backups

* Deploy to AWS 
bash
# 1. Configure AWS credentials
aws configure

# 2. Initialize Terraform
terraform init

# 3. Plan deployment
terraform plan

# 4. Deploy everything
terraform apply

# 5. Get your application URL
terraform output alb_dns_name
# Open: http://<your-alb-url>

* Cost Optimized Design
  
  EC2: t3.small instances with Auto Scaling (2-4)

  RDS: db.t3.small with Multi-AZ for high availability

  Load Balancer: Single ALB for cost efficiency

Monitoring: CloudWatch included for observability

* Production Security
  
-> Database in private subnet (no internet access)

-> EC2 instances in private subnet

-> Only Load Balancer is public-facing

-> Security groups with least privilege

-> Encrypted RDS storage

-> No SSH access from internet

* Project Structure

text
axy-devops-assignment/
│
├──  Docker Compose Files (Part 1)
│   ├── docker-compose.yml          # Run all 3 services locally
│   ├── backend/                    # Node.js API
│   │   ├── Dockerfile             # Build Node.js container
│   │   ├── server.js              # Express API with endpoints
│   │   └── package.json           # Dependencies
│   ├── frontend/                   # Web interface
│   │   ├── Dockerfile             # Build Nginx container
│   │   ├── index.html             # User interface
│   │   ├── app.js                 # Frontend JavaScript
│   │   └── nginx.conf             # Nginx configuration
│   └── scripts/                    # Database setup
│       └── init-db.sql            # Initialize PostgreSQL
│
├──  Terraform Files (Part 2)
│   ├── main.tf                    # Main infrastructure code
│   ├── variables.tf               # Configurable parameters
│   ├── outputs.tf                 # Output values (URLs, IDs)
│   ├── provider.tf                # AWS provider configuration
│   ├── terraform.tfvars           # Your specific values
│   └── ec2_user_data.sh           # Script that runs on EC2 startup
│
└──  Documentation
    ├── README.md                  # This file
    └── .gitignore                 # Git ignore rules
    
* Key Features Demonstrated
  
-> Docker & Containerization
   Multi-container orchestration

   Inter-container networking

   Volume persistence for database

   Health checks and dependencies

   Environment-based configuration

-> AWS Cloud Architecture

   VPC with public/private subnets

   EC2 Auto Scaling for high availability

   RDS PostgreSQL with backups

   Application Load Balancer

   Security groups and IAM roles

-> Infrastructure as Code

   Complete Terraform codebase

   Modular and reusable configuration

   State management

   Variable customization

-> Security Best Practices

   Principle of least privilege

   Private subnets for sensitive resources

   No public database access

   Encrypted data at rest

   Secure credential management

-> Monitoring & Maintenance

   Health checks at every layer

   Auto-scaling based on load

   Database backups enabled

   CloudWatch integration

   Logging configuration

** API Endpoints
Local Development
text
GET http://localhost:8080/api/health
Response: {"status": "healthy", "timestamp": "..."}

GET http://localhost:8080/api/message  
Response: {"message": "Hello from Axy DevOps!", "timestamp": "..."}
Production (After AWS Deployment)
text
GET http://<alb-dns-name>/api/health
GET http://<alb-dns-name>/api/message

* Testing & Verification
 Local Testing
 bash
# Verify all services are running
docker-compose ps

# Test API endpoints
curl http://localhost:8080/api/health
curl http://localhost:8080/api/message

# Check container logs
docker-compose logs backend
docker-compose logs database
Production Testing
bash
# After terraform apply
ALB_URL=$(terraform output -raw alb_dns_name)
curl http://$ALB_URL/api/health
curl http://$ALB_URL/api/message

* Performance & Scaling

 # Auto Scaling Rules
Scale Up: When CPU > 70% for 5 minutes

Scale Down: When CPU < 30% for 5 minutes

Instance Range: 2 to 4 t3.small instances

High Availability

-> Multi-AZ deployment (RDS)

->Load balancer health checks

-> Auto-replacement of unhealthy instances

-> Database failover capability

* Cleanup
Local Environment
bash
# Stop and remove containers
docker-compose down -v

# Remove Docker volumes
docker volume prune -f
AWS Environment
bash
# Destroy all AWS resources
terraform destroy

* Skills Demonstrated
  
   Skill	How It's Demonstrated
   Docker	Multi-container setup, networking, volumes
   AWS	VPC, EC2, RDS, ALB, Auto Scaling, IAM
   Terraform	Infrastructure as Code, modular design
   Security	Least privilege, private networks, encryption
   Networking	VPC design, subnetting, routing
   CI/CD	Infrastructure automation, deployment scripts
   Monitoring	Health checks, CloudWatch, logging
   Database	PostgreSQL, RDS, backups, connection pooling

* Common Issues & Solutions
  Port 8080 already in use

  bash
  # Change port in docker-compose.yml
  ports:
  - "8080:80"  # Change 9090 to another port
  AWS credentials error

  bash
  aws configure
  # Enter Access Key, Secret Key, Region (us-east-1)
  Terraform initialization error

  bash
  rm -rf .terraform
  terraform init
  Database connection failed

  Check security group rules

 Verify database endpoint

 Check credentials in environment variables


* Final Notes

This solution represents a production-ready implementation of the assignment requirements. It balances:

Simplicity: Easy to run locally with Docker

Scalability: Auto-scaling in production

Security: Follows AWS best practices

Cost Efficiency: Right-sized resources

Maintainability: Clean, documented code

The project is fully functional and can be deployed end-to-end with simple commands.

    
                    *         *          *

Built for Axy DevOps Engineer Position
Demonstrating practical DevOps skills in containerization, cloud infrastructure, and IaC


