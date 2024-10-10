# Configura el proveedor de Azure (azurerm) con las credenciales necesarias para autenticarse en la suscripción y tenant especificados.
provider "azurerm" {
  # La característica "features" se deja vacía, pero puede configurarse para habilitar características específicas de Azure.
  features {
  }
  
  # Especifica el ID de suscripción de Azure donde se desplegarán los recursos.
  subscription_id = "c7997ce2-c9d9-4add-b3d5-ab37d0a71861"
  
  # Especifica el ID del tenant de Azure (directorio) al que pertenece la suscripción.
  tenant_id = "604c1504-c6a3-4080-81aa-b33091104187"
}

# Configuración de Terraform, donde se especifica el proveedor requerido.
terraform {
  required_providers {
    # Define el proveedor "azurerm" de HashiCorp, con la versión 4.3.0 específica.
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.3.0"
    }
  }
}



