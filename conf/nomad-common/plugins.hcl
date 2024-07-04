plugin "docker" {
  config {
    allow_privileged = true
  
    volumes {
      enabled = true
    }
  }

  privileged {
    enabled = true
  }
}

plugin "nomad-driver-exec2" {
  config {
    unveil_defaults = true
    unveil_paths    = []
    unveil_by_task  = true
  }
}

plugin "qemu" {
  config {
    image_paths    = ["/srv/images"]
#    args_allowlist = ["-drive", "-usbdevice"]
  }
}