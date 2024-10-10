variable "project_name" {
  type = string
  description = "Nombre del proyecto"
}

variable "kubernetes_version" {
  type = string
  description = "Version de kubernet usada"
}

variable "location" {
  type = string
  description = "Ubicacion geografica de los recursos"
}

variable "node_count" {
  type = number
  description = "Numero de nodos del cluster de kubernet"
}

variable "dominio" {
  type = string
  description = "Dominio personalizado de prueba"
}