job "router" {
  group "opnsense" {

    #count = 0


    task "opnsense" {
      driver = "qemu"

      #artifact {
      #  source      = "https://mirror.ams1.nl.leaseweb.net/opnsense/releases/24.1/OPNsense-24.1-serial-amd64.img.bz2"
      #  destination = "/srv/images/opnsense/opnsense.img"
      #  options {
        #  checksum = "md5:df6a4178aec9fbdc1d6d7e3634d1bc33"
      #      checksum = "sha256:c4c53e5dd80660cc67b349fa588b3ca11efd9f45d09f6cb391d8e19b48dd7fcc"
      #  }
      #}

      config {
        image_path        = "/srv/images/opnsense.img"
        accelerator       = "kvm"
        graceful_shutdown = true
      }
    }
  }
}