# Multi-Cloud Auto Deployment (AWS + GCP) using Terraform

This project provisions NGINX web servers on AWS and GCP using Terraform and implements a local DNS-based failover system using DNSMasq and a Python watchdog script running in Docker.


## Features
- Deploys identical NGINX servers on AWS EC2 and GCP Compute Engine  
- Health monitoring using Python watchdog  
- Local DNS failover using DNSMasq  
- Automatic traffic switch from AWS → GCP when AWS becomes unavailable  

## Prerequisites
- Terraform  
- AWS & GCP accounts  
- Docker + Docker Compose  
- GCP service account

## How to Run
### 1. Deploy Infra
```bash
cd terraform
terraform init
terraform apply
```
### 2. Start Failover System
```bash
cd ../failover
docker compose up -d
```
### 3. Test Failover

```bash
dig @127.0.0.1 -p 53535 app.multi.local
```
Stop AWS instance → traffic switches to GCP automatically!

## Screenshots

**AWS Instance Dashboard**  
  ![AWS Instance Dashboard](./screenshots/aws_instance_dashboard.png)

**GCP Instance Dashboard**  
 ![GCP Instance Dashboard](./screenshots/gcp_instance_dashboard.png)

**AWS NGINX Output**  
 ![AWS NGINX Output](./screenshots/aws_curl.png)

**GCP NGINX Output**  
 ![GCP NGINX Output](./screenshots/gcp_curl.png)

**Docker Compose**  
 ![Docker Compose](./screenshots/docker_compose.png)

**DNSMasq Configuration**  
 ![DNSMasq Configuration](./screenshots/dnsmasq_inside_container.png)

**dig Command (AWS Active)**  
 ![dig Command (AWS Active)](./screenshots/dig_command_aws_active.png)

**curl Response (AWS)**  
 ![curl Response (AWS)](./screenshots/curl_local_dns_aws.png)

**AWS Instance Stopped**  
 ![AWS Instance Stopped](./screenshots/aws_stoppage.png)

**dig Command (After failover)**  
 ![dig Command (After failover)](./screenshots/dig_curl_gcp.png)

**Watchdog Log - Switchover Event**  
 ![Watchdog Log - Switchover Event](./screenshots/gcp_switchover_log.png)