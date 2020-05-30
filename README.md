# terraform deployment scripts for AKS with VMSS and AGIC.

Terraform deployment scripts for Azure Kubernetes Service with VMSS backed node pool with Application Gateway Ingress Controller (agic).

Even though we have official tutorials to deploy AKS cluster with AGIC and terraform, VMSS node pool was not supported from it. It's now possible with recent update to terraform provider. (Pleae refer to [tf-vmss][])

**Prerequisites**  

+ **Azure subscription:** If you don't have an Azure subscription, create a free account before you begin.

+ **Configure Terraform:** Follow the directions in the article, [config-tf][].

+ **Azure resource group:** If you don't have an Azure resource group to use for the demo, [create-rg][]. Take note of the resource group name and location as those values are used in the demo.

+ **Azure service principal:** Follow the directions in the section of the Create the service principal section in the article, [create-sp][]. Take note of the values for the appId, displayName, and password.

+ Obtain the **Service Principal Object ID:** Run the following command in Cloud Shell:  
```
  az ad sp list --display-name <displayName>
``` 
+ **Azure Storage Account & Container:** Follow the directions in the section of the Create the service principal section in the article, Create an Azure service principal with Azure CLI. Take note of the values for the appId, displayName, and password.


* **Deployment Steps:**  

```
# Intialize terraform
terraform init -backend-config="storage_account_name=_<Storage Account Name>" -backend-config="container_name=tfstate" -backend-config="access_key=_<Storage Account Key>" -backend-config="key=cmbt-tf-aks.microsoft.tfstate"

# Planning deployment
terraform plan -out out.plan

# Execute deployment
terraform apply "out.plan"

# Print out the result of deployment related to identity assignment.
echo "$(terraform output identity_resource_id)"
echo "$(terraform output identity_client_id)"

# Update helm-chart.yaml with result of commands above.
```

* **AGIC Helm Chart Install (from Cloud shell with K8S version > 1.16.x):**

```
helm install ingress-azure \
  -f helm-config.yaml \
  application-gateway-kubernetes-ingress/ingress-azure \
  --version 1.2.0-rc1
```

* **References:**

[tutorial]: https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-aks-applicationgateway-ingress
**Tutorial: Create an Application Gateway ingress controller in Azure Kubernetes Service**

[storage-setup]: https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-aks-applicationgateway-ingress#configure-azure-storage-to-store-terraform-state
**Configure Azure storage to store Terraform state**  

[tf-vmss]: https://www.danielstechblog.io/terraform-working-with-aks-multiple-node-pools-in-tf-azure-provider-version-1-37/
**Terraform – Working with AKS multiple node pools in TF Azure provider version 1.37**

[config-tf]: https://docs.microsoft.com/en-us/azure/developer/terraform/install-configure

[create-rg]: https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#create-resource-groups

[create-sp]: https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest

