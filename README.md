# Weather App – Azure IaC (Terraform)

This repository contains the Infrastructure as Code (Terraform) for the
Weather App hackathon project, deployed on Microsoft Azure.

## Stack (Azure-native)
- Azure Container Registry (ACR)
- Azure Container Apps (frontend + backend)
- Azure Front Door (TLS + /api routing)
- Azure Database for MySQL Flexible Server
- Log Analytics for observability

Application code lives in a separate repository:
➡ weather-app (frontend + backend + CI)

## Usage

```bash
cd terraform
terraform init
terraform plan
terraform apply
