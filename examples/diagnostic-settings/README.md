<!-- BEGIN_TF_DOCS -->
# Default example

This deploys the module in its simplest form.

```hcl
terraform {
  required_version = ">= 1.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.63.0, < 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.3.2, < 4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.4.1, < 4.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
  storage_use_azuread        = false
}

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

```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.3)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.63.0, < 4.0)

- <a name="requirement_http"></a> [http](#requirement\_http) (>= 3.4.1, < 4.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.3.2, < 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>= 3.63.0, < 4.0)

- <a name="provider_http"></a> [http](#provider\_http) (>= 3.4.1, < 4.0)

- <a name="provider_random"></a> [random](#provider\_random) (>= 3.3.2, < 4.0)

## Resources

The following resources are used by this module:

- [azurerm_key_vault.storage_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) (resource)
- [azurerm_key_vault_access_policy.current_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) (resource)
- [azurerm_key_vault_key.storage_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) (resource)
- [azurerm_log_analytics_storage_insights.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_storage_insights) (resource)
- [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) (resource)
- [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) (resource)
- [random_string.table_acl_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) (resource)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [http_http.ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_key_vault_firewall_bypass_ip_cidr"></a> [key\_vault\_firewall\_bypass\_ip\_cidr](#input\_key\_vault\_firewall\_bypass\_ip\_cidr)

Description: n/a

Type: `string`

Default: `null`

### <a name="input_managed_identity_principal_id"></a> [managed\_identity\_principal\_id](#input\_managed\_identity\_principal\_id)

Description: n/a

Type: `string`

Default: `null`

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: 0.4.0

### <a name="module_storage_account"></a> [storage\_account](#module\_storage\_account)

Source: ../..

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->