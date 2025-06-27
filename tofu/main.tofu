resource "vultr_instance" "postgresql" {
  count       = 1
  plan        = "vc2-1c-1gb"
  region      = "fra"
  os_id       = "2284"
  enable_ipv6 = true
  ssh_key_ids = ["${vultr_ssh_key.root.id}"]
  tags        = ["elephantproject", "postgresql"]
}

resource "vultr_ssh_key" "root" {
  name    = "postgresql - root - public key"
  ssh_key = file("~/.ssh/root/id_ed25519.pub")
}

output "inventory" {
  value = templatefile(
    "${path.module}/templates/inventory.ini.tmpl",
    {
      postgresql = vultr_instance.postgresql.*.main_ip
    }
  )
}