terraform {
  backend "azurerm" {
    resource_group_name  = "rg-skycastnow-tfstate"
    storage_account_name = "tfstateskycastnow19471"
    container_name       = "tfstate"
    key                  = "skycastnow.terraform.tfstate"
  }
}
