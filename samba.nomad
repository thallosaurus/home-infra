job "fileserver" {
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

    service {
      name = "samba"
      port = "smb"

      check {
        name     = "Smb Check"
        type     = "tcp"
        protocol = "smb"
        interval = "10s"
        timeout  = "2s"
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
        destination = "smb.conf"
        data        = file("./samba/smb.conf")
      }

      env {
        USER = "akasha"
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/env.vars"
        env         = true
        data        = <<EOF
{{- with nomadVar "nomad/jobs" -}}
PASS={{ .root_password }}
{{- end -}}
EOF
      }

      volume_mount {
        volume      = "fs"
        destination = "/mnt"
        read_only   = false
      }

      config {
        image = "dockurr/samba"
        ports = ["smb"]

        mount {
          type   = "bind"
          target = "/etc/samba/smb.conf"
          source = "smb.conf"
        }
      }
    }
  }

  group "seaweedfs" {
    network {
      port "http" {
        to = "8333"
      }

      port "filer" {
        to = "8888"
      }

      port "s3" {
      }

      port "webdav" {

      }
    }

    service {
      name = "seaweedfs-s3"
      port = "s3"
      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.sws3.rule=Host(`s3.apps.cyber.psych0si.is`) && PathPrefix(`/`)",
        "traefik.http.routers.sws3.entrypoints=http",
      ]
    }

    service {
      name = "webdav"
      port = "webdav"

      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.swwebdav.rule=Host(`webdav.apps.cyber.psych0si.is`) && PathPrefix(`/`)",
        "traefik.http.routers.swwebdav.entrypoints=http,https",
      ]
    }

    service {
      name = "filer"
      port = "filer"

      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.swfiler.rule=Host(`filer.apps.cyber.psych0si.is`) && PathPrefix(`/`)",
        "traefik.http.routers.swfiler.entrypoints=http",
      ]
    }

    volume "data" {
      type            = "csi"
      read_only       = false
      source          = "nfs_seaweedfs"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }


    task "seaweedfs" {
      driver = "docker"
      template {
        destination = "local/config.json"
        data        = file("s3/config.json")
      }

      volume_mount {
        volume      = "data"
        destination = "/data"
        read_only   = false
      }

      config {
        image = "chrislusf/seaweedfs"
        args  = ["server", "-s3", "-s3.port=${NOMAD_PORT_s3}", "-s3.config=/config.json", "-dir=/data", "-filer=true", "-webdav", "-webdav.port=${NOMAD_PORT_webdav}"]
        ports = ["http", "s3", "webdav", "filer"]

        mount {
          type   = "bind"
          target = "/config.json"
          source = "local/config.json"
        }
      }
    }
  }

  group "nfs" {
    network {
      port "nfs" {
        static = "2049"
        to     = "2049"
      }
      port "rpc" {
        static = "111"
        to     = "111"
      }
    }

    volume "fs" {
      type      = "host"
      read_only = false
      source    = "samba-fs"
    }

    task "nfs" {
      driver = "docker"

      template {
        destination = "local/exports"
        data        = <<EOH
/mnt/nfs/grafana  10.0.0.0/24(rw,no_subtree_check,insecure,no_root_squash)
/mnt/nfs/influxdb  10.0.0.0/24(rw,no_subtree_check,insecure,no_root_squash)
/mnt/nfs/prometheus  10.0.0.0/24(rw,no_subtree_check,insecure,no_root_squash)
/mnt/nfs/homeassistant  10.0.0.0/24(rw,no_subtree_check,insecure,no_root_squash)
/mnt/nfs/gitea  10.0.0.0/24(rw,no_subtree_check,insecure,no_root_squash)
/mnt/nfs/mysql  10.0.0.0/24(rw,no_subtree_check,insecure,no_root_squash)
/mnt/nfs/gitness  10.0.0.0/24(rw,no_subtree_check,insecure,no_root_squash)
/mnt/nfs/seaweedfs  10.0.0.0/24(rw,no_subtree_check,insecure,no_root_squash)
        EOH
      }

      volume_mount {
        volume      = "fs"
        destination = "/mnt"
        read_only   = false
      }


      config {
        privileged   = true
        image        = "erichough/nfs-server"
        ports        = ["nfs", "rpc"]
        network_mode = "host"

        mount {
          type   = "bind"
          target = "/etc/exports"
          source = "local/exports"
        }
      }
    }
  }
}