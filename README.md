# 🚀 End-to-End DevOps Project on Azure 🚀

Welcome to a comprehensive DevOps project demonstrating a full CI/CD lifecycle on Microsoft Azure. This repository showcases how to provision a production-ready environment using **Terraform** and automate application deployment to **Azure Kubernetes Service (AKS)** with **Azure DevOps Pipelines**.

![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Azure DevOps](https://img.shields.io/badge/Azure%20DevOps-0078D7?style=for-the-badge&logo=azuredevops&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

---

## 🎯 Project Goal

The primary objective is to build a secure, scalable, and fully automated environment for a containerized application. This project covers everything from writing Infrastructure as Code (IaC) to configuring a multi-stage CI/CD pipeline that handles building, versioning, and deploying the application.

### ✨ Key Features
* **Fully Automated Infrastructure:** All Azure resources are defined as code using Terraform for repeatable and consistent environments.
* **CI/CD Automation:** The entire build and deployment process is automated with Azure Pipelines, triggered by code changes in the repository.
* **Containerized Application:** The backend application is containerized with Docker and deployed to a managed Kubernetes cluster (AKS).
* **Secure Networking:** A custom Virtual Network (VNet) with subnets and Network Security Groups (NSGs) provides a secure and isolated environment for the application.

---

## 🏗️ Project Architecture

The diagram below illustrates the complete workflow, from a developer pushing code to the final application running in AKS.

![Project Blueprint](https://i.imgur.com/gJ5Bf2e.png)

---

## 🛠️ Getting Started

Follow these steps to replicate the environment and deployment.

### Prerequisites
* An Azure Subscription
* Azure CLI installed and configured
* Terraform installed
* An Azure DevOps organization and project
* Your Azure DevOps organization granted the free parallelism grant (see [https://aka.ms/azpipelines-parallelism-request](https://aka.ms/azpipelines-parallelism-request))

### Step 1: 🌐 Provision the Azure Infrastructure

All the necessary Azure resources are defined in the `/terraform` directory.

1.  Navigate to the `terraform` directory:
    ```bash
    cd terraform
    ```
2.  Initialize Terraform:
    ```bash
    terraform init
    ```
3.  Review the execution plan:
    ```bash
    terraform plan
    ```
4.  Apply the configuration to create the resources in Azure. This will take 10-15 minutes.
    ```bash
    terraform apply
    ```
    *This will create the VNet, subnets, NSG rules, AKS cluster, and ACR.*

### Step 2: ⚙️ Configure the Azure DevOps Pipeline

The CI/CD pipeline is defined in the `azure-pipelines.yml` file at the root of this repository.

1. **Create Service Connections:** In your Azure DevOps project settings, create two service connections:
   * An **"Azure Resource Manager"** connection named `Azure-Subscription-Connection`.
   * A **"Kubernetes"** connection named `AKS-Kube-Connection`, pointing to the AKS cluster you just created.
2. **Create an Environment:** In Azure DevOps under **Pipelines -> Environments**, create a new environment named `MyWebAppAKS` and link it to your AKS cluster.
3. **Install Marketplace Extension:** Install the [Replace Tokens](https://marketplace.visualstudio.com/items?itemName=qetza.replacetokens) extension into your Azure DevOps organization.
4. **Update Pipeline Variables:** Edit the `azure-pipelines.yml` file in Azure Repos and replace the placeholder values for `acrLoginServer` with the output from your Terraform deployment.

### Step 3: 🚀 Trigger the Pipeline

The pipeline is configured to trigger automatically when changes are pushed to the `app/` or `manifests/` directories.

1. Make a small change to a file in the `app/backend/` directory (e.g., add a comment).
2. Commit and push the change to your repository.
   ```bash
   git add .
   git commit -m "Triggering CI/CD pipeline"
   git push
   ```
3. Navigate to the "Pipelines" section in Azure DevOps to watch the build and deploy stages run in real-time.

### Step 4: ✅ Verify the Deployment

Once the pipeline has completed successfully, you can verify that the application is running in your AKS cluster.

1. Connect `kubectl` to your cluster:
   ```bash
   az aks get-credentials --resource-group MyWebAppResourceGroup --name MyWebAppAKSCluster
   ```
2. Check the running pods and services:
   ```bash
   kubectl get pods
   kubectl get services
   ```
   *You should see the `backend-api` pods in a "Running" state.*

---

This project serves as a practical, real-world example of implementing modern DevOps practices on the Azure cloud platform.
