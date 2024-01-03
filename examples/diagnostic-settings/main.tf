resource "random_pet" "this" {
  length = 1
}

resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name_unique
  location = "AustraliaEast"
}

resource "random_string" "table_acl_id" {
  length  = 64
  special = false
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
}

resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.user_assigned_identity.name_unique
  resource_group_name = azurerm_resource_group.this.name
}

module "storage_account" {
  source = "../.."
  # source  = "kewalaka/res-storage-storageaccount/azurerm"
  # version = "0.1.0"

  account_replication_type      = "LRS"
  account_tier                  = "Standard"
  account_kind                  = "StorageV2"
  name                          = module.naming.storage_account.name_unique
  resource_group_name           = azurerm_resource_group.this.name
  shared_access_key_enabled     = true
  public_network_access_enabled = true

  tags = {
    env   = "dev"
    owner = "IT"
  }
  role_assignments = {
    role_assignment_1 = {
      role_definition_id_or_name       = "Contributor"
      principal_id                     = data.azurerm_client_config.current.object_id
      skip_service_principal_aad_check = false
    },

  }

  managed_identities = {
    identity_ids = {
      msi = azurerm_user_assigned_identity.this.id
    }
    type = "UserAssigned"
  }
  customer_managed_key = {
    key_name              = azurerm_key_vault_key.storage_key.name
    key_vault_resource_id = azurerm_key_vault.storage_vault.id
  }
  containers = {
    blob_container1 = {
      name                  = "blob-container-${random_pet.this.id}-1"
      container_access_type = "private"
    }
    blob_container2 = {
      name                  = "blob-container-${random_pet.this.id}-2"
      container_access_type = "private"
    }
    blob_container3 = {
      name                  = "blob-container-${random_pet.this.id}-3"
      container_access_type = "private"
    }
  }
  queues = {
    queue1 = {
      name = "queue-${random_pet.this.id}-1"
    }
    queue2 = {
      name = "queue-${random_pet.this.id}-2"
    }
    queue3 = {
      name = "queue-${random_pet.this.id}-3"
    }
  }
  shares = {
    share1 = {
      name  = "share-${random_pet.this.id}-1"
      quota = 50
    }
    share2 = {
      name  = "share-${random_pet.this.id}-2"
      quota = 50
    }
  }

  tables = {
    table0 = {
      name = "table${random_pet.this.id}a"
    }
    table1 = {
      name = "table${random_pet.this.id}b"
    }
  }

  blob_properties = {
    diagnostic_settings = {
      blob11 = {
        name                       = "diag"
        log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
        category_group             = ["audit", "alllogs"]
        metric_categories          = ["AllMetrics"]
      }
    }
  }

  queue_properties = {
    diagnostic_settings = {
      queue = {
        name                       = "diag"
        log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
        category_group             = ["audit", "alllogs"]
        metric_categories          = ["AllMetrics"]
      }
    }
  }
  share_properties = {
    diagnostic_settings = {
      share = {
        name                       = "diag"
        log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
        category_group             = ["audit", "alllogs"]
        metric_categories          = ["AllMetrics"]
      }
    }
  }
}

