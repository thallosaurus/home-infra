job "databases" {
  type = "service"
  group "mysql" {
    constraint {
      attribute = "${node.unique.name}"
      value     = "snappy"
    }
    network {
      port "mysql" {
        to     = "3306"
        static = "3306"
      }
    }

    service {
      name = "mysql"
      port = "mysql"

      #check {
      #  name     = "MySQL Port Check"
      #  type     = "tcp"
      #  interval = "10s"
      #  timeout  = "2s"
      #}
    }

    volume "data" {
      type            = "csi"
      read_only       = false
      source          = "nfs_mysql"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    task "mysql" {
      driver = "docker"

      volume_mount {
        volume      = "data"
        destination = "/var/lib/mysql"
        read_only   = false
      }

      env {
        MYSQL_ROOT_PASSWORD = "test"
      }

      config {
        image = "mysql"
        ports = ["mysql"]
      }

      resources {
        cpu    = 1000 # 500 MHz
        memory = 1024 # 512 MB
      }
    }
  }

  group "pma" {
    network {
      port "http" {
        to = "80"
      }
    }

    service {
      name = "pma"
      port = "http"
      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.pma.rule=Host(`pma.apps.cyber.psych0si.is`) && PathPrefix(`/`)",
        "traefik.http.routers.pma.entrypoints=http",
      ]
      #provider = "nomad"

      check {
        name     = "PMA Frontend Check"
        path     = "/"
        type     = "http"
        protocol = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "pma" {
      driver = "docker"

      env {
        PMA_HOST = "mysql.service.consul"
        PMA_USER = "pma"
        PMA_PASSWORD = "pma123"
      }

      config {
        image = "phpmyadmin"
        ports = ["http"]
      }


    }
  }
}