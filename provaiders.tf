provider "azurerm" {
  features {
  }
  subscription_id = "c7997ce2-c9d9-4add-b3d5-ab37d0a71861"
  tenant_id = "604c1504-c6a3-4080-81aa-b33091104187"
}

terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "=4.3.0"
    }
  }
}


