# Clear.Bank Practical Task
Here is my submission for the Clear.Bank practical task, developed on a Mac using Terraform v1.6.4 

## Variables

I've created a variable to hold a list of Azure Service Bus Namespaces for a particular environment. Each namespace in the list has:
* a name
* the associated cost centre and product name 
* a list of queue names


Here's an example of a `.tfvars` file for the `test` environment:
```yaml
environment_name = "test"

service_bus_namespaces = [
  {
    name         = "payg"
    cost_centre  = "finance"
    product_name = "payments gateway"
    queues       = ["one", "two"]
  },
  {
    name         = "crm"
    cost_centre  = "sales"
    product_name = "crm"
    queues       = ["alpha", "beta"]
  }
]
```

## main.tf
The [main.tf](main.tf) sets up the providers and declares a couple of locals. The `queues_by_namespace` local is a projection of the above structure to easier iterate and create queues per namespace. The resulting structure looks like so (given the above input):
```yaml
[
  { namespace: "payg", name: "one" },
  { namespace: "payg", name: "two" },
  { namespace: "crm",  name: "alpha" },
  { namespace: "crm",  name: "beta" }
]
```


## service_bus.tf
Inside [service_bus.tf](service_bus.tf) the `service_bus_namespaces` variable is iterated over creating a resource group for each namespace. It is iterated again to create a service bus namespace inside the associated resource group with tags added for cost centre, product name and additionally the environment. 
Finally the `queues_by_namespace` projection is iterated to create the queues for each namespace.

All of the Azure resources are named using the following convention:

```
cb-{environment}-{namespace}-{optional queue name}-{azure resource abbreviation}
```

Where
* `environment` is the environment name e.g. test, staging, production
* `azure resource abbreviation` is taken from [this list](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)


The projections for the resource group and namespace in the `for-each` use the name of the service bus namespace as the key. This value is chosen as it is stable - changes to the key will destroy and create new resources.
Likewise the key used for the queues consists of `{namespace}_{queue name}`, again changing the namespace or the queue name will destroy and create resources.

## Testing
Run `tf test` to run the tests (requires terraform v1.6.0 or later). 
The tests are declared in [service_bus.tftest.hcl](service_bus.tftest.hcl) and check that the resource group, service bus namespace and queues are correctly named. More tests can be added to test various scenarios such as multiple namespaces / queues etc.

Example test run
```bash
❯ tf test
service_bus.tftest.hcl... in progress
  run "Ensure resource groups are created with correct name"... pass
  run "Ensure service bus namespaces are created with correct name"... pass
  run "Ensure queues are created with correct name"... pass
service_bus.tftest.hcl... tearing down
service_bus.tftest.hcl... pass
```

## Plan / Apply / Destroy
I've added three example `.tfvars` files to the repository to make running straightforward. 

To run
```zsh
terraform plan -var-file={env}.tfvars -out={env}.out 
terraform apply "{env}.out"
terraform destroy -var-file={env}.tfvars
```

where `{env}` is one of `test`, `staging` or `production`.
 
I've included my copy of `test.out` - to view the plan run `terraform show "test.out"`

## Where next
What I haven't done
* Configured the namespace and queues in any meaningful way.
* Used premium features such as high throughput, scaling, network security, Geo-disaster and recovery etc 
* Incorporated a CI / CD pipeline to automate linting, static analysis (tfsec, checkov, etc.), deployment (automatic / gated), etc. 
* Created a module - If the structure were to be repeated anywhere
* Security hardening / least privilege - Ensure resources are only as visible as they need be depending on resource and requirements, e.g. no internet ingress, vnet / subnet restrictions, private endpoints etc. Ideally specify particular access rights to resources for each environment - e.g. engineers may have full access to test, and limited access to production. 
