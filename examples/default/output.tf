# illustrate what the outputs look like
output "resource_id" {
  description = "Example illustrating how to fetch the resource id."
  value       = module.storage_account.resource.id
}
