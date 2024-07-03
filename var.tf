variable "proxmox_api_url" {
  default = "https://10.245.189.105:8006/api2/json"
  type    = string
}

variable "proxmox_api_token_id" {
  default = "root@pam!pevteste2"
  type    = string
}

variable "proxmox_api_token_secret" {
  default   = "94ea44bd-d4c3-47f3-af2b-723696cb5ac6"
  type      = string
  sensitive = true
}