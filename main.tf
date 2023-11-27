terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.82.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"

  queues_by_namespace = distinct(flatten([
    for namespace in var.service_bus_namespaces : [
      for queue in toset(namespace.queues) : {
        namespace = namespace.name
        name      = queue
      }
    ]
  ]))
}
