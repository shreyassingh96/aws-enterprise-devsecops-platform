# Enterprise AWS DevSecOps Platform Architecture

## High-Level Architecture Overview

This platform is designed to provide a secure, scalable, and highly available infrastructure for containerized workloads. It follows a modular, GitOps-driven approach based on industry best practices.

### 1. Network Foundation (VPC)
- **Multi-AZ Deployment:** Subnets are spread across at least 3 Availability Zones (AZs) for high availability.
- **Public & Private Subnets:**
  - **Public Subnets:** Host ALBs, NAT Gateways, and Bastion Hosts (if necessary).
  - **Private Subnets:** Host EKS Worker Nodes, RDS databases, and Redis clusters. Direct internet access is blocked.
- **Egress Routing:** Private subnets route to the internet via NAT Gateways located in the public subnets.
- **Security Groups:** Strict, least-privilege security groups control ingress and egress traffic between components.

### 2. Compute (Amazon EKS)
- **Managed Kubernetes:** EKS serves as the orchestration layer for all microservices.
- **Node Groups:** Managed Node Groups using a mix of On-Demand and Spot instances (depending on environment) to balance cost and reliability.
- **Cluster Autoscaler:** Automatically scales node groups based on pod resource requirements.
- **Horizontal Pod Autoscaler (HPA):** Scales application pods based on CPU/Memory utilization.

### 3. Data Storage
- **Relational DB:** Amazon RDS for PostgreSQL, deployed in private subnets with Multi-AZ enabled for production.
- **Caching:** Amazon ElastiCache for Redis, deployed in private subnets.
- **Object Storage:** Amazon S3 with KMS encryption for static assets and backups.

### 4. CI/CD & GitOps
- **Continuous Integration:** Jenkins pipelines compile code, run tests, execute security scans (Trivy, Checkov), build Docker images, and push them to Amazon ECR.
- **Continuous Deployment (GitOps):** ArgoCD monitors a dedicated Git repository for Kubernetes manifest changes (Helm/Kustomize) and automatically syncs the cluster state.
- **Infrastructure Pipeline:** Terraform changes are applied via CI/CD pipelines incorporating Checkov/tfsec scans for IAC security.

### 5. Security Architecture
- **Encryption:**
  - **In Transit:** TLS certificates via AWS Certificate Manager (ACM) applied at the ALB.
  - **At Rest:** AWS KMS managed keys encrypt EBS volumes, RDS, ECR, and S3.
- **IAM Least Privilege:** Dedicated IAM roles for EKS nodes, and IRSA (IAM Roles for Service Accounts) for individual pods to access AWS services (e.g., S3, Secrets Manager).
- **Secrets Management:** AWS Secrets Manager securely stores DB credentials, API keys, and ArgoCD secrets. External Secrets Operator injects these into Kubernetes.
- **Scanning:**
  - **Containers:** Trivy scans ECR images and running pods.
  - **IAC:** Checkov scans Terraform code.

### 6. Observability
- **Metrics:** Prometheus scrapes cluster and application metrics.
- **Dashboards:** Grafana visualizes metrics (CPU, Memory, API latency).
- **Logging:** Fluent Bit captures container logs and ships them to Loki (or CloudWatch/ELK).
- **Alerting:** Alertmanager integrates with Slack/PagerDuty for incident notification.

---

## Deployment Flow
1. **Developer Commits Code:** Code is pushed to the application repository.
2. **CI Pipeline Triggers:** Builds application, runs unit tests, static code analysis (SonarQube).
3. **Container Build & Scan:** Docker image is built, scanned for vulnerabilities (Trivy), and pushed to ECR.
4. **Manifest Update:** CI pipeline updates the Kubernetes manifest (e.g., Helm chart version) in the GitOps repository.
5. **GitOps Sync:** ArgoCD detects the manifest change and applies the new configuration to the EKS cluster.
6. **Deployment:** EKS rolling update replaces old pods with new ones. Health checks ensure stability.

## Scaling Considerations
- **Application Level:** HPA scales pods based on real-time metrics.
- **Infrastructure Level:** Cluster Autoscaler provisions new EC2 instances when pods are pending due to resource constraints.
- **Database Level:** RDS read replicas can be added to offload read traffic.
