End-to-End DevOps Project: Deploying a Containerized Application on Azure
This repository contains the code and configuration for a complete DevOps project that demonstrates how to provision a production-ready environment on Microsoft Azure using Terraform and automate the deployment of a containerized application using Azure DevOps Pipelines.

Project Architecture
The project provisions a secure and scalable infrastructure on Azure and deploys a simple backend API application to Azure Kubernetes Service (AKS). The entire workflow, from infrastructure creation to application deployment, is automated.

Core Components:

Infrastructure as Code (IaC): All Azure resources are defined and managed using Terraform.

CI/CD: Azure Pipelines is used to create a multi-stage pipeline that automatically builds a Docker image and deploys it to the Kubernetes cluster.

Source Control: All code, including the application, Terraform scripts, and pipeline definitions, is stored in this Git repository.

Technologies Used
Cloud Provider: Microsoft Azure

Infrastructure as Code: Terraform

CI/CD: Azure DevOps (Azure Pipelines, Azure Repos)

Containerization: Dockergit push -u origin main

Orchestration: Azure Kubernetes Service (AKS)

Version Control: Git

How to Use This Project
Follow these steps to replicate the environment and deployment.

Prerequisites
An Azure Subscription

Azure CLI installed and configured

Terraform installed

An Azure DevOps organization and project

Your Azure DevOps organization granted the free parallelism grant (see https://aka.ms/azpipelines-parallelism-request)

Step 1: Provision the Azure Infrastructure
All the necessary Azure resources are defined in the /terraform directory.

Navigate to the terraform directory:

cd terraform

Initialize Terraform:

terraform init

Review the execution plan:

terraform plan

Apply the configuration to create the resources in Azure. This will take 10-15 minutes.

terraform apply

This will create the VNet, subnets, NSG rules, AKS cluster, and ACR.

Step 2: Configure the Azure DevOps Pipeline
The CI/CD pipeline is defined in the azure-pipelines.yml file at the root of this repository.

Create Service Connections: In your Azure DevOps project settings, create two service connections:

An "Azure Resource Manager" connection named Azure-Subscription-Connection.

A "Kubernetes" connection named AKS-Kube-Connection, pointing to the AKS cluster you just created.

Create an Environment: In Azure DevOps under Pipelines -> Environments, create a new environment named MyWebAppAKS and link it to your AKS cluster.

Install Marketplace Extension: Install the Replace Tokens extension into your Azure DevOps organization.

Update Pipeline Variables: Edit the azure-pipelines.yml file in Azure Repos and replace the placeholder values for acrLoginServer with the output from your Terraform deployment.

Step 3: Trigger the Pipeline
The pipeline is configured to trigger automatically when changes are pushed to the app/ or manifests/ directories.

Make a small change to a file in the app/backend/ directory (e.g., add a comment).

Commit and push the change to your repository.

git add .
git commit -m "Triggering CI/CD pipeline"
git push

Navigate to the "Pipelines" section in Azure DevOps to watch the build and deploy stages run in real-time.

Step 4: Verify the Deployment
Once the pipeline has completed successfully, you can verify that the application is running in your AKS cluster.

Connect kubectl to your cluster:

az aks get-credentials --resource-group MyWebAppResourceGroup --name MyWebAppAKSCluster

Check the running pods and services:

kubectl get pods
kubectl get services

You should see the backend-api pods in a "Running" state.

This project serves as a practical, real-world example of implementing modern DevOps practices on the Azure cloud platform.
