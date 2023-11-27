variables {
  environment_name = "envname"
  service_bus_namespaces = [
    {
      name         = "ns"
      cost_centre  = "cost_centre"
      product_name = "product_name"
      queues       = ["queue"]
    }
  ]
}

run "Ensure resource groups are created with correct name" {

  command = plan

  assert {
    condition     = azurerm_resource_group.sbns_rg["ns"].name == "cb-envname-ns-sbns-rg"
    error_message = "Resource group name did not match expected"
  }
}

run "Ensure service bus namespaces are created with correct name" {

  command = plan

  assert {
    condition     = azurerm_servicebus_namespace.sbns["ns"].name == "cb-envname-ns-sbns"
    error_message = "Resource group name did not match expected"
  }
}

run "Ensure queues are created with correct name" {

  command = plan

  assert {
    condition     = azurerm_servicebus_queue.sbq["ns_queue"].name == "cb-envname-ns-queue-sbq"
    error_message = "Queue name did not match expected"
  }
}
