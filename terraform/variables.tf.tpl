variable "env" {
  type = "map"

  default = {
    region          = ""
    subscription_id = ""
    client_id       = ""
    client_secret   = ""
    tenant_id       = ""
    vm_size         = "Standard_A0"
    admin_username  = ""
    ssh_key         = ""
  }
}
