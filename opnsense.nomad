job "router" {
  group "opnsense" {

    #count = 0


    task "opnsense" {
      driver = "qemu"

      artifact {
        source      = "https://downloads.freepbxdistro.org/ISO/SNG7-PBX16-64bit-2302-1.iso"
        destination = "/srv/images/freepbx.iso"
      #  options {
        #  checksum = "md5:df6a4178aec9fbdc1d6d7e3634d1bc33"
      #      checksum = "sha256:c4c53e5dd80660cc67b349fa588b3ca11efd9f45d09f6cb391d8e19b48dd7fcc"
      #  }
      }

      config {
        image_path        = "/srv/images/freepbx.iso"
        accelerator       = "kvm"
        graceful_shutdown = true
      }
    }
  }
}