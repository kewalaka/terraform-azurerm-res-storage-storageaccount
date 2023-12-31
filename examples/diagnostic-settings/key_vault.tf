data "azurerm_client_config" "current" {}

data "http" "ip" {
  url = "https://ifconfig.me/ip"
}

locals {
  # We cannot use coalesce here because it's not short-circuit and public_ip's index will cause error
  public_ip = var.key_vault_firewall_bypass_ip_cidr == null ? data.http.ip.response_body : var.key_vault_firewall_bypass_ip_cidr
}

resource "azurerm_key_vault" "storage_vault" {
  location                    = azurerm_resource_group.this.location
  name                        = module.naming.key_vault.name_unique
  resource_group_name         = azurerm_resource_group.this.name
  sku_name                    = "premium"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = true
  purge_protection_enabled    = true
  soft_delete_retention_days  = 7

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = [local.public_ip]
  }
}

resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.storage_vault.id
  object_id    = coalesce(var.managed_identity_principal_id, data.azurerm_client_config.current.object_id)
  tenant_id    = data.azurerm_client_config.current.tenant_id
  key_permissions = [
    "Get",
    "Create",
    "Delete",
    "List",
    "Restore",
    "Recover",
    "UnwrapKey",
    "WrapKey",
    "Purge",
    "Encrypt",
    "Decrypt",
    "Sign",
    "Verify",
    "GetRotationPolicy",
    "SetRotationPolicy",
  ]
}

resource "azurerm_key_vault_key" "storage_key" {
  #checkov:skip=CKV_AZURE_112:HSM is overkill for an example.
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  key_type        = "RSA"
  key_vault_id    = azurerm_key_vault.storage_vault.id
  name            = "storagekey${random_pet.this.id}"
  expiration_date = timeadd("${formatdate("YYYY-MM-DD", timestamp())}T00:00:00Z", "168h")
  key_size        = 2048

  depends_on = [azurerm_key_vault_access_policy.current_user]

  lifecycle {
    ignore_changes = [expiration_date]
  }
}
