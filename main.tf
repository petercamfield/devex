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

resource "azurerm_resource_group" "sbns_rg" {
  for_each = { for namespace in var.service_bus_namespaces : namespace.name => namespace }
  name     = "cb-${var.environment_name}-${each.key}-sbns-rg"
  location = var.location

  tags = {
    cost_centre      = each.value.cost_centre
    product_name     = each.value.product_name
    environment_name = var.environment_name
  }

  lifecycle {
    prevent_destroy = true
  }
}