packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}

source "qemu" "example" {
  #iso_url          = "http://ftp.riken.jp/Linux/centos-vault/centos/6.9/isos/x86_64/CentOS-6.9-x86_64-minimal.iso"
  iso_url = "https://archives.fedoraproject.org/pub/archive/fedora/linux/releases/32/Server/x86_64/iso/Fedora-Server-netinst-x86_64-32-1.6.iso"
  #  iso_checksum     = "md5:af4a1640c0c6f348c6c41f1ea9e192a2"
  iso_checksum     = "sha256:7f4afd2a26c718f9f15e4bbfd9c2e8849f81036d2a82a4e81fa4a313a833da9c"
  output_directory = "output_centos_tdhtest"
  shutdown_command = "echo 'packer' | sudo -S /sbin/poweroff"
  disk_size        = "5000M"
  format           = "qcow2"
  accelerator      = "tcg"
  http_directory   = "./http_dir"
  ssh_username     = "vagrant"
  ssh_password     = "vagrant"
  ssh_timeout      = "20m"
  vm_name          = "tdhtest"
  net_device       = "virtio-net"
  disk_interface   = "virtio"
  boot_wait        = "10s"
  boot_command     = ["<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/fedora-ks.cfg<enter><wait>"]
  headless         = true
}

build {
  sources = ["source.qemu.example"]
}