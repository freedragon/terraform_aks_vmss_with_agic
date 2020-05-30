# terraform deployment scripts for AKS with VMSS and AGIC.

Terraform deployment scripts for Azure Kubernetes Service with VMSS backed node pool with Application Gateway Ingress Controller (agic).

#References:

**Tutorial: Create an Application Gateway ingress controller in Azure Kubernetes Service**
https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-aks-applicationgateway-ingress

**Terraform – Working with AKS multiple node pools in TF Azure provider version 1.37**
https://www.danielstechblog.io/terraform-working-with-aks-multiple-node-pools-in-tf-azure-provider-version-1-37/

**AGIC Helm Chart Install (from Cloud shell with K8S version > 1.16.x):**

> helm install ingress-azure \
>   -f helm-config.yaml \
>   application-gateway-kubernetes-ingress/ingress-azure \
>   --version 1.2.0-rc1
