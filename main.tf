# Crea un grupo de recursos en Azure donde se almacenarán todos los recursos.
resource "azurerm_resource_group" "rg" {
  name = "${var.project_name}_rg"
  location = var.location
}

# Crea un registro de contenedores en Azure para almacenar imágenes Docker.
resource "azurerm_container_registry" "acr" {
  name = "${var.project_name}acr"
  resource_group_name = azurerm_resource_group.rg.name
  location = var.location
  sku = "Basic"
  admin_enabled = true
}

# Despliega un clúster de Kubernetes (AKS) en Azure.
resource "azurerm_kubernetes_cluster" "aks" {
  node_resource_group = "${azurerm_resource_group.rg.name}_node"
  name = "${var.project_name}_aks"
  kubernetes_version = var.kubernetes_version
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix = "${var.project_name}dns"
  
  # Etiqueta para indicar el ambiente del clúster.
  tags = {
    Eniroment = "Prueba"
  }
  
  # Configura el grupo de nodos para el clúster.
  default_node_pool {
    name = "agentpool"
    node_count = var.node_count
    vm_size = "Standard_B2s"
  }

  # Configura la identidad administrada del clúster.
  identity {
    type = "SystemAssigned"
  }

  http_application_routing_enabled = false
}

# Crea una dirección IP pública estática con SKU estándar.
resource "azurerm_public_ip" "public_ip" {
  name = "${var.project_name}-ippublica"
  location = azurerm_kubernetes_cluster.aks.location
  resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
  allocation_method = "Static"
  sku = "Standard"
  sku_tier = "Regional"
}

# Crea una zona DNS para administrar el dominio en Azure.
resource "azurerm_dns_zone" "dns" {
  name = var.dominio
  resource_group_name = azurerm_resource_group.rg.name
}

# Crea un registro DNS tipo A, apuntando la zona DNS a la IP pública.
resource "azurerm_dns_a_record" "rc" {
  name = "@"
  zone_name = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl = 1
  records = ["${azurerm_public_ip.public_ip.ip_address}"]
}

# Configura el proveedor Helm, utilizando la configuración del clúster AKS.
provider "helm" {
  kubernetes {
    host = azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}

# Despliega el Nginx Ingress Controller en el clúster de Kubernetes usando Helm Chart.
resource "helm_release" "ingress-nginx" {
  name = "ingress-nginx"
  namespace = "ingress-basic"
  create_namespace = true
  chart = "ingress-nginx/ingress-nginx"
  version = "4.10.1"
  timeout = 600
  reuse_values = true
  recreate_pods = true
  cleanup_on_fail = true
  wait = true
  verify = false

  # Define la cantidad de réplicas del controlador Nginx Ingress.
  set {
    name = "controller.replicaCount"
    value = var.node_count + 1
  }

  # Establece la afinidad del controlador para ejecutar en nodos con sistema operativo Linux.
  set {
    name = "controller.nodeSelector.kubernetes\\.io/os"
    value = "linux"
  }

  # Establece la afinidad del backend predeterminado para Linux.
  set {
    name = "defaultBackend.nodeSelector.Kubernetes\\.io/os"
    value = "linux"
  }

  # Configura el controlador de servicio con la IP pública estática creada.
  set {
    name = "controller.service.loadBalancerIP"
    value = "${azurerm_public_ip.public_ip.ip_address}"
  }
}
