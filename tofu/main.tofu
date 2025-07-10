resource "vultr_instance" "postgresql" {
  count       = 2
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

resource "local_file" "openssl_config" {
  content  = templatefile(
    "${path.module}/templates/openssl.cnf.tmpl",
    {
      etcd = vultr_instance.etcd.*.main_ip
    }
  )
  filename = pathexpand("~/.elephantproject/ssl/openssl.cnf")
  file_permission = "0664"
}

resource "null_resource" "openssl_certificates" {
  count = fileexists(pathexpand("~/.elephantproject/ssl/openssl.cnf")) ? 0 : 1
  depends_on = [ local_file.openssl_config ]

  provisioner "local-exec" {
    when = create
    command = "sh ${path.module}/scripts/ssl/generate.sh -c ${pathexpand("~/.elephantproject/ssl/openssl.cnf")}"
  }

  provisioner "local-exec" {
    when = destroy
    command = "sh ${path.module}/scripts/ssl/destroy.sh"
  }

}
