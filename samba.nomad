job "smb" {
  type = "service"
  group "samba" {
    constraint {
      attribute = "${node.unique.name}"
      value     = "fileserver"
    }
    network {
      port "smb" {
        to     = 445
        static = 445
      }
    }

    volume "fs" {
      type      = "host"
      read_only = false
      source    = "samba-fs"
    }

    task "samba" {
      driver = "docker"

      template {
        destination = "smb_testfile.txt"
        data        = "Hello World!"
      }

      template {
        destination = "smb.conf"
        data        = file("./smb/smb.conf")
      }

      env {
        USER = "user"
        PASS = "user"
      }

      volume_mount {
        volume      = "fs"
        destination = "/mnt"
        read_only   = false
      }
      
      config {
        image = "dockurr/samba"
        ports = ["smb"]


        mounts = [
          {
            type   = "bind"
            target = "/storage/smb_testfile.txt"
            source = "smb_testfile.txt"
          },
          {
            type   = "bind"
            target = "/etc/samba/smb.conf"
            source = "smb.conf"
          }
        ]
      }
    }
  }
}