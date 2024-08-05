client {
  enabled = true
  servers = ["10.0.0.1"]
  options = {
    "driver.raw_exec.enable" = "1"
  }

  host_volume "minecraft-data" {
    path      = "/opt/minecraft"
    read_only = false
  }

    host_volume "samba-fs" {
    path      = "/mnt/nfs"
    read_only = false
  }
}