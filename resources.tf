# # Locals block for hardcoded names. 
locals {
    backend_address_pool_name      = "${azurerm_virtual_network.cmbt_tf_poc_vnet.name}-beap"
    frontend_port_name             = "${azurerm_virtual_network.cmbt_tf_poc_vnet.name}-feport"
    frontend_ip_configuration_name = "${azurerm_virtual_network.cmbt_tf_poc_vnet.name}-feip"
    http_setting_name              = "${azurerm_virtual_network.cmbt_tf_poc_vnet.name}-be-htst"
    listener_name                  = "${azurerm_virtual_network.cmbt_tf_poc_vnet.name}-httplstn"
    request_routing_rule_name      = "${azurerm_virtual_network.cmbt_tf_poc_vnet.name}-rqrt"
    app_gateway_subnet_name        = var.app_gateway_name
}

data "azurerm_resource_group" "cmbt_tf_poc_resourcegroup" {
  name = var.resource_group_name
}

# User Assigned Identities 
resource "azurerm_user_assigned_identity" "clusterIdentity" {
  resource_group_name = data.azurerm_resource_group.cmbt_tf_poc_resourcegroup.name
  location            = data.azurerm_resource_group.cmbt_tf_poc_resourcegroup.location

  name = var.azurerm_user_assigned_identity_name
  tags = var.tags
}

# User Assigned Identities for Node Resource Group
/*
resource "azurerm_user_assigned_identity" "clusterNodeRGIdentity" {
  resource_group_name = azurerm_kubernetes_cluster.k8s.node_resource_group
  location            = azurerm_kubernetes_cluster.k8s.location

  name = var.azurerm_user_assigned_nrg_identity_name
  tags = var.tags
  depends_on = [azurerm_kubernetes_cluster.k8s, azurerm_virtual_network.cmbt_tf_poc_vnet, azurerm_public_ip.cmbt_tf_poc_pip1,azurerm_application_gateway.network]
}
*/

resource "azurerm_virtual_network" "cmbt_tf_poc_vnet" {
  name                = var.virtual_network_name
  location            = data.azurerm_resource_group.cmbt_tf_poc_resourcegroup.location
  resource_group_name = data.azurerm_resource_group.cmbt_tf_poc_resourcegroup.name
  address_space       = [var.virtual_network_address_prefix]

  subnet {
    name           = var.aks_subnet_name
    address_prefix = var.aks_subnet_address_prefix
  }

  subnet {
    name           = var.app_gateway_name
    address_prefix = var.app_gateway_subnet_address_prefix
  }

  tags = var.tags
}

data "azurerm_subnet" "kubesubnet" {
  name                 = var.aks_subnet_name
  virtual_network_name = azurerm_virtual_network.cmbt_tf_poc_vnet.name
  resource_group_name  = data.azurerm_resource_group.cmbt_tf_poc_resourcegroup.name
}

data "azurerm_subnet" "appgwsubnet" {
  name                 = var.app_gateway_name
  virtual_network_name = azurerm_virtual_network.cmbt_tf_poc_vnet.name
  resource_group_name  = data.azurerm_resource_group.cmbt_tf_poc_resourcegroup.name
}

# Public Ip 
resource "azurerm_public_ip" "cmbt_tf_poc_pip1" {
  name                         = "cmbt-tf-pip1"
  location                     = data.azurerm_resource_group.cmbt_tf_poc_resourcegroup.location
  resource_group_name          = data.azurerm_resource_group.cmbt_tf_poc_resourcegroup.name
  allocation_method            = "Static"
  sku                          = "Standard"

  tags = var.tags
}

resource "azurerm_application_gateway" "network" {
  name                = var.app_gateway_name
  resource_group_name = data.azurerm_resource_group.cmbt_tf_poc_resourcegroup.name
  location            = data.azurerm_resource_group.cmbt_tf_poc_resourcegroup.location

  sku {
    name     = var.app_gateway_sku
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = data.azurerm_subnet.appgwsubnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_port {
    name = "httpsPort"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.cmbt_tf_poc_pip1.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  tags = var.tags

  depends_on = [azurerm_virtual_network.cmbt_tf_poc_vnet, azurerm_public_ip.cmbt_tf_poc_pip1]
}

resource "azurerm_role_assignment" "ra1" {
  scope                = data.azurerm_subnet.kubesubnet.id
  role_definition_name = "Network Contributor"
  principal_id         = var.aks_service_principal_object_id 

  depends_on = [azurerm_virtual_network.cmbt_tf_poc_vnet]
}

resource "azurerm_role_assignment" "ra2" {
  scope                = azurerm_user_assigned_identity.clusterIdentity.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = var.aks_service_principal_object_id
  # principal_id         = azurerm_user_assigned_identity.clusterIdentity.principal_id
  depends_on           = [azurerm_user_assigned_identity.clusterIdentity]
}

resource "azurerm_role_assignment" "ra3" {
  scope                = azurerm_application_gateway.network.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.clusterIdentity.principal_id
  depends_on           = [azurerm_user_assigned_identity.clusterIdentity, azurerm_application_gateway.network]
}

resource "azurerm_role_assignment" "ra4" {
  scope                 = data.azurerm_resource_group.cmbt_tf_poc_resourcegroup.id
  role_definition_name  = "Reader"
  principal_id          = azurerm_user_assigned_identity.clusterIdentity.principal_id
  depends_on            = [azurerm_user_assigned_identity.clusterIdentity, azurerm_application_gateway.network]
}

/*
resource "azurerm_role_assignment" "ranrg1" {
  principal_id          = azurerm_user_assigned_identity.clusterNodeRGIdentity.principal_id
  role_definition_name  = "Contributor"
  scope                = azurerm_application_gateway.network.id
  depends_on            = [azurerm_user_assigned_identity.clusterNodeRGIdentity]
}

resource "azurerm_role_assignment" "ranrg2" {
  principal_id          = azurerm_user_assigned_identity.clusterNodeRGIdentity.principal_id
  role_definition_name  = "Reader"
  scope                 = data.azurerm_resource_group.cmbt_tf_poc_resourcegroup.id
  depends_on            = [azurerm_user_assigned_identity.clusterNodeRGIdentity]
}
*/

resource "azurerm_kubernetes_cluster" "k8s" {
  name                  = var.aks_name
  location              = data.azurerm_resource_group.cmbt_tf_poc_resourcegroup.location
  dns_prefix            = var.aks_dns_prefix
  resource_group_name   = data.azurerm_resource_group.cmbt_tf_poc_resourcegroup.name
  kubernetes_version    = var.kubernetes_version

  linux_profile {
    admin_username = var.vm_user_name

    ssh_key {
      key_data = file(var.public_ssh_key_path)
    }
  }

  addon_profile {
    http_application_routing {
      enabled = false
    }
  }

  default_node_pool {
    name                = var.default_node_pool.name
    type                = var.default_node_pool.type
    max_pods            = var.default_node_pool.max_pods
    node_count          = var.default_node_pool.node_count
    vm_size             = var.default_node_pool.vm_size
    os_disk_size_gb     = var.default_node_pool.os_disk_size_gb
    vnet_subnet_id      = data.azurerm_subnet.kubesubnet.id
    /*
      ** taints sample **

      taints = [
        "kubernetes.io/os=Windows:NoSchedule"
      ]
    */
    node_taints          = var.default_node_pool.taints
    availability_zones   = var.default_node_pool.zones
    enable_auto_scaling	 = var.default_node_pool.cluster_auto_scaling
    min_count	         = var.default_node_pool.cluster_auto_scaling_min_count
    max_count            = var.default_node_pool.cluster_auto_scaling_max_count
  }

  service_principal {
    client_id            = var.aks_service_principal_app_id
    client_secret        = var.aks_service_principal_client_secret
  }

  network_profile {
    network_plugin       = "azure"
    dns_service_ip       = var.aks_dns_service_ip
    docker_bridge_cidr   = var.aks_docker_bridge_cidr
    service_cidr         = var.aks_service_cidr
  }

  depends_on = [azurerm_virtual_network.cmbt_tf_poc_vnet, azurerm_application_gateway.network]
  tags                   = var.tags
}

