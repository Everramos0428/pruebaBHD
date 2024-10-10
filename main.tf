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

#Azure DevOps
resource "azurerm_role_assignment" "arcpull" {
  scope = azurerm_container_registry.acr.id
  role_definition_name = "ArcPull"
  principal_id = azurerm_kubernetes_cluster.aks.kubelet_identify.0.object_id
}

#VM sonarqube
resource "azurerm_virtual_network" "network" {
  depends_on = [ 
    azurerm_resource_group.rg
   ]
  name = "${var.project_name}-network"
  address_space = ["10.0.0.0/16"]
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg-name
}

#Create Subnet
resource "azurerm_subnet" "Subnet" {
  name = "${var.project_name}-subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes = ["10.0.2.0/24"] 
}

resource "azurerm_network_security_group" "sq_sg" {
  name = "${var.project_name}-sq_sg"
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name = "${var.project_name}_sq_out_sg"
    priority = 100
    direction = "Outbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name = "SSH"
    priority = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_ranges = "22"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name = "SONARQUBE"
    priority = 1002
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_ranges = "9000"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

#IP publica del sonarqube
resource "azurerm_public_ip" "sq_ip" {
  name = "${var.project_name}-sp_ip"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Static"
  sku = "Standard"
  sku_tier = "Regional"
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

#subdominio de aks
resource "azurerm_dns_a_record" "rc" {
  name = var.subdomain_app_aks
  zone_name = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl = 1
  records = ["${azurerm_public_ip.public.ip.ip_address}"]
}

#subdominio de sonar
resource "azurerm_dns_a_record" "rc" {
  name = var.subdomain_sonarqube
  zone_name = azurerm_dns_zone.dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl = 1
  records = ["${azurerm_public_ip.sq_public.ip.ip_address}"]
}

resource "azurerm_network_interface" "sq-nic" {
  name = "${var.project_name}-sq-nic"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "${var.project_name}-sq_nic_config"
    subnet_id = azurerm_subnet.Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sq_public_ip.id
  }
}

# Connect the newtwork security group to the network interface
resource "azurerm_network_interface_security_group_association" "sg_association" {
  network_interface_id      = azurerm_network_interface.sq-nic.id
  #subnet_id = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.sq_sg.id
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "sq_storage_account" {
  name                     = "${var.project_name}diagstorage"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create SSH key
resource "tls_private_key" "sq_key_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "sq_vm" {
  name                  = "${var.project_name}-sq-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.sq-nic.id]
  size                  = "Standard_B2s"

  os_disk {
    name                 = "${var.project_name}-disk_os"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version = "latest"
  }

  computer_name                   = "vm-sq"
  admin_username                  = var.user_vm_sq
  disable_password_authentication = true
  custom_data = filebase64("scripts/install_sonarqube.sh")

  admin_ssh_key {
    username   = var.user_vm_sq
    public_key = tls_private_key.sq_key_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.sq_storage_account.primary_blob_endpoint
  }
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
  chart = "./chart/ingress-nginx-4.3.0.tgz"
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
