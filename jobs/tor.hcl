job "tor" {
  group "tor" {
    constraint {
      attribute = "${node.unique.name}"
      value     = "pi4"
    }
    network {
      port "http" {
        to     = "8118"
        static = "8118"
      }

      port "socks" {
        to     = "9050"
        static = "9050"
      }
    }

    service {
      name = "tor"
      port = "socks"
    }


    task "tor" {
      driver = "docker"

      template {
        destination = "local/torrc"
        data        = <<EOH
# managed by nomad
AutomapHostsOnResolve 1
ControlPort 9051
ControlSocket /etc/tor/run/control
ControlSocketsGroupWritable 1
CookieAuthentication 1
CookieAuthFile /etc/tor/run/control.authcookie
CookieAuthFileGroupReadable 1
DNSPort 5353
DataDirectory /var/lib/tor
ExitPolicy reject *:*
Log info stderr
RunAsDaemon 0
SocksPort 0.0.0.0:9050 IsolateDestAddr
TransPort 0.0.0.0:9040
User tor
VirtualAddrNetworkIPv4 10.192.0.0/10

{{ range service "obfsproxy" -}}
#Socks5Proxy {{ .Address }}:{{ .Port }}
{{ end }}
      EOH
      }

      config {
        image = "dperson/torproxy"
        ports = ["http", "socks"]

        mount {
          type   = "bind"
          target = "/etc/tor/torrc"
          source = "local/torrc"
        }
      }
    }
  }

  group "obfsproxy" {

    constraint {
      attribute = "${node.unique.name}"
      value     = "rastaman"
    }

    network {
      port "socks" {
        to = "14321"
        static = "14321"
      }
    }

    service {
      name = "obfsproxy"
      port = "socks"
    }

    task "obfsproxy" {
      driver = "docker"

      config {
        image = "derenderkeks/obfsproxy"
        ports = ["socks"]
        args  = ["obfsproxy", "--log-file=/dev/stdout", "--log-min-severity=info", "obfs3", "socks", "0.0.0.0:14321"]
      }
    }
  }
}