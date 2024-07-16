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

    volume "backup" {
      type      = "host"
      read_only = true
      source    = "samba-backup"
    }

    task "samba" {
      driver = "docker"

      template {
        destination = "smb.conf"
        data        = file("./appdata/samba/smb.conf")
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

      volume_mount {
        volume      = "backup"
        destination = "/baclup"
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
      port "master" {
        to = "9333"
      }

      port "filer" {
        to = "8888"
      }

      port "s3" {
      }

      port "webdav" {

      }

      port "volserver" {
        to = "8080"
      }
    }

    #service {
    #  name = "weedmaster"
    #  port = "master"
    #}

    service {
      name = "s3"
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
        "traefik.http.routers.swwebdav.entrypoints=https",
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
        data        = file("acls/s3.json")
      }

      volume_mount {
        volume      = "data"
        destination = "/data"
        read_only   = false
      }

      config {
        image = "chrislusf/seaweedfs"
        args  = ["server", "-s3", "-s3.port=${NOMAD_PORT_s3}", "-s3.config=/config.json", "-dir=/data", "-filer=true"]
        //, "-webdav", "-webdav.port=${NOMAD_PORT_webdav}"]
        ports = ["master", "s3", "webdav", "filer"]

        mount {
          type   = "bind"
          target = "/config.json"
          source = "local/config.json"
        }
      }
    }
  }

  group "webdav" {
    constraint {
      attribute = "${node.unique.name}"
      value     = "snappy"
    }
    network {
      port "webdav" {
        to     = "80"
        static = "30303"
      }
    }

    volume "keepass-store" {
      type            = "csi"
      read_only       = false
      source          = "nfs_keepass_store"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    task "webdav" {
      driver = "docker"
      env {
        AUTH_TYPE = "Digest"
        USERNAME  = "rillo"
      }

      volume_mount {
        volume      = "keepass-store"
        destination = "/var/lib/dav"
        read_only   = false
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/env.vars"
        env         = true
        data        = <<EOF
{{- with nomadVar "nomad/jobs" -}}
PASSWORD={{ .root_password }}
{{- end -}}
EOF
      }

      config {
        //docker run --restart always -v /srv/dav:/var/lib/dav \
        //-e AUTH_TYPE=Digest -e USERNAME=alice -e PASSWORD=secret1234 \
        //--publish 80:80 -d bytemark/webdav

        image = "bytemark/webdav"
        ports = ["webdav"]

      }
    }
  }

  group "nfs" {
    count = 0
    network {
      port "nfs" {
        static = "2049"
        to     = "2049"
      }
      port "rpc" {
        static = "111"
        to     = "111"
      }

      port "v3-1" {
        static = "32765"
        to     = "32765"
      }
      port "v3-2" {
        static = "32767"
        to     = "32767"
      }
    }

    volume "fs" {
      type      = "host"
      read_only = false
      source    = "samba-fs"
    }


    task "nfs" {
      driver = "docker"

      resources {
        memory = 300
      }


      env {
        NFS_LOG_LEVEL = "DEBUG"
      }

      template {
        destination = "local/exports"
        data        = <<EOH
/mnt/nfs/grafana  10.0.0.0/24(rw,no_subtree_check,insecure,no_root_squash)
/mnt/nfs/influxdb  10.0.0.0/24(rw,no_subtree_check,insecure,no_root_squash)
/mnt/nfs/prometheus  10.0.0.0/24(rw,no_subtree_check,insecure,no_root_squash)
/mnt/nfs/homeassistant  10.0.0.0/24(rw,no_subtree_check,insecure,no_root_squash)
/mnt/nfs/seaweedfs  10.0.0.0/24(rw,no_subtree_check,insecure,no_root_squash)
/mnt/nfs/keepass  10.0.0.0/24(rw,no_subtree_check,insecure,no_root_squash)
/mnt/nfs/ytdl  10.0.0.0/24(rw,no_subtree_check,insecure,no_root_squash)
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
        ports        = ["nfs", "rpc", "v3-1", "v3-2"]
        network_mode = "host"
        #        cap_add = ["sys_admin", "sys_module"]

        mount {
          type   = "bind"
          target = "/etc/exports"
          source = "local/exports"
        }
      }
    }
  }
}