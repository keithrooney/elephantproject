variable "vultr_api_key" {
  sensitive = true
}

variable "vultr_region" {
  default = "ewr"
}

variable "vultr_backup_storage_size" {
  default = 500
}

variable "vultr_os_id" {
  default = "2284"
}

variable "vultr_instance_plan" {
  default = "vc2-1c-1gb"
}
