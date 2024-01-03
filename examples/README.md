# Examples

This module is for the Azure storage account.  The following examples illustrate the use of this module:

|Example |Description|
|--|--|
| [default](./default/) | Create a storage account using the default parameters in this module. |
| [diagnostic-settings](./database/) | Creates storage blobs, queues, shares & tables, along with per sub-resource diagnostic settings. |
| [private_endpoint](./private_endpoint/) | Storage account with multiple private endpoints for different sub-resources (blob, queue, and table). |
| [simple-container](./database_with_existing_server/) | A simple example illustrating a storage account and one blob container. |

## Contributing new examples

> [!NOTE]
> Examples must be deployable and idempotent. Ensure that no input variables are required to run the example and that random values are used to ensure unique resource names. E.g. use the [naming module](https://registry.terraform.io/modules/Azure/naming/azurerm/latest) to generate a unique name for a resource.

New examples to test functionality or illustrate use cases are welcome.

- Create a directory for each example.
- Create a `_header.md` file in each directory to describe the example.
- See the `default` example provided as a skeleton - this must remain, but you can add others.
- Run `make fmt && make docs` from the repo root to generate the required documentation.
