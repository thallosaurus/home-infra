client {
  enabled = true
  servers = ["10.0.0.1"]
  options = {
    "driver.raw_exec.enable" = "1"
  }

  host_volume "samba-fs" {
    path      = "/mnt"
    read_only = false
  }

  host_volume "samba-backup" {
    path      = "/backup"
    read_only = true
  }
}