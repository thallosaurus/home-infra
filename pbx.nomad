job "pbx" {
  group "pbx" {
    constraint {
      attribute = "${node.unique.name}"
      value     = "snappy"
    }

    network {
      port "http" {
        to = "80"
      }

      port "https" {
        to = "443"
      }

      #port "fop" {
      #  to = "4445"
      #}

      #port "iax" {
      #  to = "4569"
      #}

      port "pjsip" {
        to = "5060"
        static = "5060"
      }

      port "sip" {
        to = "5160"
        static = "5160"
      }

      #port "ucp" {
      #  to = "8001"
      #}

      #port "ucp_ssl" {
      #  to = "8003"
      #}

      #port "ucp2" {
      #  to = "8008"
      #}

      #      port "ucp_ssl2" {
      #        to = "8009"
      #      }
    }

    service {
      name = "freepbx"
      port = "http"
      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.fpbx.rule=Host(`freepbx.apps.cyber.psych0si.is`) && PathPrefix(`/`)",
        "traefik.http.routers.fpbx.entrypoints=http",
      ]
      #provider = "nomad"

      #check {
      #  name = "FreePBX Frontend Check"
        #path     = "/api/healthz"
      #  path     = "/"
      #  type     = "http"
      #  protocol = "http"
      #  interval = "10s"
      #  timeout  = "2s"
      #}
    }

    volume "data" {
      type      = "host"
      read_only = true
      source    = "pbx-data"
    }

    task "pbx" {
      driver = "docker"

      # docker run -d -p 80:80 -p 443:443 -p 4445:4445 -p 4569:4569 -p 5060:5060 -p 5160:5160 -p 8001:8001 -p 8003:8003 -p 8008:8008 -p 8009:8009 --name test1 tiredofit/freepbx

      env {
        ADMIN_PASSWORD = "test123"
        FAIL2BAN_ENABLE = "false"
        #ENABLE_FAIL2BAN = "false"
        DEBUG_MODE      = "TRUE"
      }

      volume_mount {
        volume      = "data"
        destination = "/data"
        #propagation_mode = "private"
      }

      config {
        image = "flaviostutz/freepbx:latest"
        privileged = true
        ports = [
          "http",
          "https",
          #    "fop",
          #    "iax",
          "pjsip",
          "sip",
          #    "ucp",
          #    "ucp_ssl",
          #    "ucp2",
          #    "ucp_ssl2"
        ]
      }
    }
  }
}