client {
  enabled = true
  servers = ["10.0.0.1"]
  options = {
    "driver.raw_exec.enable" = "1"
  }

  host_volume "pihole-data" {
    path      = "/opt/pihole"
    read_only = false
  }
}