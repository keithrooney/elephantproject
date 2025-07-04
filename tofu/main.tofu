resource "vultr_instance" "postgresql" {
  count       = 1
  plan        = "vc2-1c-1gb"
  region      = "fra"
  os_id       = "2284"
  enable_ipv6 = true
  ssh_key_ids = ["${vultr_ssh_key.root.id}"]
  tags        = ["elephantproject", "postgresql"]
  label       = "postgresql[${count.index}]"
}

resource "vultr_ssh_key" "root" {
  name    = "postgresql - root - public key"
  ssh_key = file("~/.ssh/root/id_ed25519.pub")
}

resource "vultr_instance" "etcd" {
  count       = 3
  plan        = "vc2-1c-1gb"
  region      = "fra"
  os_id       = "2284"
  enable_ipv6 = true
  ssh_key_ids = ["${vultr_ssh_key.root.id}"]
  tags        = ["elephantproject", "etcd"]
  label       = "etcd[${count.index}]"
}

output "openssl" {
  value = templatefile(
    "${path.module}/templates/openssl.cnf.tmpl",
    {
      etcd = vultr_instance.etcd.*.main_ip
    }
  )
}