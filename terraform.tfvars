#
# Some variables has default values. Please refer to variables.tf for declarations and defaults
#
resource_group_name                 = "cmbt-tf-aks01-rg"
location                            = "koreancentral"
aks_service_principal_app_id        = "947593ca-3295-4af2-b0a7-6bafcc210f7c"
aks_service_principal_client_secret = "96e3bf9a-6d72-4910-be30-b6f6f73a6bec"
aks_service_principal_object_id     = "aeb0d2fe-5dcd-4ba1-8d67-ea52c662e56d"

azurerm_user_assigned_identity_name = "cmbt-tf-aks03-id"
azurerm_user_assigned_nrg_identity_name = "cmbt-tf-aks03-nrg-id"

virtual_network_name                = "cmbt-tf-poc-vnet"
virtual_network_address_prefix      = "123.0.0.0/8"

aks_subnet_name                     = "cmbt-tf-aks-subnet"
aks_subnet_address_prefix           = "123.0.0.0/16"
app_gateway_subnet_name             = "cmbt-tf-apgw-subnet"
app_gateway_subnet_address_prefix   = "123.1.0.0/16"
app_gateway_name                    = "cmbt-tf-apgw01"
app_gateway_sku                     = "Standard_v2"
app_gateway_tier                    = "Standard_v2"

aks_name                            = "cmbt-tf-aks-qa02"
aks_dns_prefix                      = "cmbt-tf-aks-qa02"
aks_enable_rbac                     = "false"
kubernetes_version                  = "1.16.9"

# Old variables. Replaced with default_node_pool variable (MAP type at the end)
aks_agent_os_disk_size              = 256
aks_agent_count                     = 3
aks_agent_vm_size                   = "Standard_D3_v2"

vm_user_name                        = "yonghp"
public_ssh_key_path                 = "~/.ssh/id_rsa.pub"

tags = {
    target: "QA", project: "Commbot"
}
default_node_pool = {
    name                            = "defnodepool"
    type                            = "VirtualMachineScaleSets"
    node_count                      = 3
    vm_size                         = "Standard_D3_v2"
    max_pods                        = 60
    os_disk_size_gb                 = 256
    zones                           = null
    taints                          = null
    cluster_auto_scaling            = true
    cluster_auto_scaling_min_count  = 3
    cluster_auto_scaling_max_count  = 30
}

