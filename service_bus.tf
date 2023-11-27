resource "azurerm_resource_group" "sbns_rg" {
  for_each = { for namespace in var.service_bus_namespaces : namespace.name => namespace }
  name     = "cb-${var.environment_name}-${each.key}-sbns-rg"
  location = local.location

  tags = {
    cost_centre      = each.value.cost_centre
    product_name     = each.value.product_name
    environment_name = var.environment_name
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_servicebus_namespace" "sbns" {
  for_each            = { for namespace in var.service_bus_namespaces : namespace.name => namespace }
  name                = "cb-${var.environment_name}-${each.key}-sbns"
  location            = azurerm_resource_group.sbns_rg[each.key].location
  resource_group_name = azurerm_resource_group.sbns_rg[each.key].name
  sku                 = "Basic"

  tags = {
    cost_centre      = each.value.cost_centre
    product_name     = each.value.product_name
    environment_name = var.environment_name
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_servicebus_queue" "sbq" {
  for_each     = { for queue in local.queues_by_namespace : "${queue.namespace}_${queue.name}" => queue }
  name         = "cb-${var.environment_name}-${each.value.namespace}-${each.value.name}-sbq"
  namespace_id = azurerm_servicebus_namespace.sbns[each.value.namespace].id

  lifecycle {
    prevent_destroy = true
  }
}
