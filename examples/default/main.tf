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
  # source  = "kewalaka/res-storage-storageaccount/azurerm"
  # version = "0.1.0"
  name                = module.naming.storage_account.name_unique
  resource_group_name = azurerm_resource_group.this.name
}
