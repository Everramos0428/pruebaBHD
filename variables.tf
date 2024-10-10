# Nombre del proyecto que se utilizará para nombrar varios recursos en la infraestructura.
variable "project_name" {
  type        = string
  description = "Nombre único asignado al proyecto, utilizado para identificar y nombrar los recursos dentro de Azure."
}

# Versión específica de Kubernetes que se utilizará para desplegar el clúster en Azure.
variable "kubernetes_version" {
  type        = string
  description = "La versión exacta de Kubernetes que se usará para configurar el clúster AKS (Azure Kubernetes Service)."
}

# Región o ubicación geográfica en la que se desplegarán los recursos dentro de Azure.
variable "location" {
  type        = string
  description = "La ubicación geográfica o región en la que se desplegarán los recursos de Azure, como el clúster de Kubernetes, el registro de contenedores y otros servicios."
}

# Cantidad de nodos que se desplegarán en el clúster de Kubernetes.
variable "node_count" {
  type        = number
  description = "Número de nodos de agente que se crearán en el grupo de nodos del clúster de Kubernetes."
}

# Nombre del dominio de prueba personalizado que se utilizará para las pruebas de configuración del DNS.
variable "dominio" {
  type        = string
  description = "Dominio personalizado que se utilizará para configurar la zona DNS dentro de Azure como parte del entorno de pruebas."
}
