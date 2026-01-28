data "terraform_remote_state" "infra" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.tfstate_resource_group
    storage_account_name = var.tfstate_storage_account
    container_name       = var.tfstate_container
    key                  = "infra.tfstate"
  }
}