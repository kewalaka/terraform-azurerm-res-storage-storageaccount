# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
}

resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name_unique
  location = "AustraliaEast"
}

module "storage_account" {
  source = "../../"
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  name                = module.naming.storage_account.name_unique
  resource_group_name = azurerm_resource_group.this.name

  account_replication_type = "LRS"
  account_tier             = "Standard"

  containers = {
    blob_container = {
      name = module.naming.storage_container.name_unique
    }
  }
}
