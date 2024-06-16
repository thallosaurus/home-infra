job "dns" {
  type = "service"

  update {
    auto_revert  = true
    max_parallel = 3
  }

  group "bind" {
    constraint {
      attribute = "${node.unique.name}"
      value     = "snappy"
    }

    network {
      port "dns" {
        to     = "53"
        static = "53"
      }
    }

    task "bind9" {
      driver = "docker"
      template {
        destination = "tmp/named.conf.local"
        data        = file("./bind/named.conf.local")
      }

      template {
        destination = "tmp/named.conf.options"
        data        = file("./bind/named.conf.options")
      }

      template {
        destination = "tmp/db.0.0.10.in-addr.arpa"
        data        = file("./bind/db.0.0.10.in-addr.arpa")
      }

      template {
        destination = "tmp/db.int.cyber.psych0si.is"
        data        = file("./bind/db.int.cyber.psych0si.is")
      }

      template {
        destination = "tmp/db.apps.cyber.psych0si.is"
        data        = file("./bind/db.apps.cyber.psych0si.is")
      }

      config {
        image = "ubuntu/bind9"
        ports = ["dns"]
        mounts = [
          {
            type   = "bind"
            target = "/etc/bind/zones/db.int.cyber.psych0si.is"
            source = "tmp/db.int.cyber.psych0si.is"
          },
          {
            type   = "bind"
            target = "/etc/bind/zones/db.apps.cyber.psych0si.is"
            source = "tmp/db.apps.cyber.psych0si.is"
          },
          {
            type   = "bind"
            target = "/etc/bind/zones/db.0.0.10.in-addr.arpa"
            source = "tmp/db.0.0.10.in-addr.arpa"
          },
          {
            type   = "bind"
            target = "/etc/bind/named.conf.options"
            source = "tmp/named.conf.options"
          },
          {
            type   = "bind"
            target = "/etc/bind/named.conf.local"
            source = "tmp/named.conf.local"
          }
        ]
      }
    }
  }
}