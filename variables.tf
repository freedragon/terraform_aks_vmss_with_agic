variable "resource_group_name" {
  description = "Name of the resource group."
}

variable "location" {
  description = "Location of the cluster."
}

variable "aks_service_principal_app_id" {
  description = "Application ID/Client ID  of the service principal. Used by AKS to manage AKS related resources on Azure like vms, subnets."
}

variable "aks_service_principal_client_secret" {
  description = "Secret of the service principal. Used by AKS to manage Azure."
}

variable "aks_service_principal_object_id" {
  description = "Object ID of the service principal."
}

variable "azurerm_user_assigned_nrg_identity_name" {
  description = "Name of user assigned identiy for node resource group"
}

variable "azurerm_user_assigned_identity_name" {
  description = "Name of user assigned identiy"
}

variable "virtual_network_name" {
  description = "Virtual network name"
}

variable "virtual_network_address_prefix" {
  description = "Containers DNS server IP address."
}

variable "aks_subnet_name" {
  description = "AKS Subnet Name."
}

variable "aks_subnet_address_prefix" {
  description = "Containers DNS server IP address."
}

variable "app_gateway_subnet_name" {
  description = "AKS Subnet Name."
}

variable "app_gateway_subnet_address_prefix" {
  description = "Containers DNS server IP address."
}

variable "app_gateway_name" {
  description = "Name of the Application Gateway."
}

variable "app_gateway_sku" {
  description = "Name of the Application Gateway SKU."
}

variable "app_gateway_tier" {
  description = "Tier of the Application Gateway SKU."
}

variable "aks_name" {
  description = "Name of the AKS cluster."
}

variable "aks_dns_prefix" {
  description = "Optional DNS prefix to use with hosted Kubernetes API server FQDN."
}

variable "aks_agent_os_disk_size" {
  description = "Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 applies the default disk size for that agentVMSize."
  default     = 256
}

variable "aks_agent_count" {
  description = "The number of agent nodes for the cluster."
  default     = 3
}

variable "aks_agent_vm_size" {
  description = "The size of the Virtual Machine."
  default     = "Standard_D3_v2"
}

variable "kubernetes_version" {
  description = "The version of Kubernetes."
}

variable "aks_service_cidr" {
  description = "A CIDR notation IP range from which to assign service cluster IPs."
  default     = "10.0.0.0/16"
}

variable "aks_dns_service_ip" {
  description = "Containers DNS server IP address."
  default     = "10.0.0.10"
}

variable "aks_docker_bridge_cidr" {
  description = "A CIDR notation IP for Docker bridge."
  default     = "172.17.0.1/16"
}

variable "aks_enable_rbac" {
  description = "Enable RBAC on the AKS cluster. Defaults to false."
}

variable "vm_user_name" {
  description = "User name for the VM"
}

variable "public_ssh_key_path" {
  description = "Public key path for SSH."
}

variable "tags" {
  type = map

  default = {
    source = "terraform"
  }
}

variable "default_node_pool" {
  description = "The object to configure the default node pool with number of worker nodes, worker node VM size and Availability Zones."
  type = object({
    name                           = string
    type                           = string
    node_count                     = number
    vm_size                        = string
    zones                          = list(string)
    taints                         = list(string)
    max_pods                       = number
    os_disk_size_gb                = number
    cluster_auto_scaling           = bool
    cluster_auto_scaling_min_count = number
    cluster_auto_scaling_max_count = number
  })
}

/*
 * Additional node pool settings for future use.
 *
variable "additional_node_pools" {
  description = "The map object to configure one or several additional node pools with number of worker nodes, worker node VM size and Availability Zones."
  type = map(object({
    node_count                     = number
    vm_size                        = string
    zones                          = list(string)
    taints                         = list(string)
    cluster_auto_scaling           = bool
    cluster_auto_scaling_min_count = number
    cluster_auto_scaling_max_count = number
  }))
}
 */
