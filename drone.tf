resource "docker_image" "drone" {
  name = "drone/drone:2"
}

resource "docker_volume" "drone-data" {
  name = "drone-data"
}

resource "docker_container" "drone" {
  name  = "drone"
  image = docker_image.drone.image_id

  mounts {
    target = "/var/run/docker.sock"
    type   = "bind"
    source = "/var/run/docker.sock"
  }

  volumes {
    container_path = "/data"
    volume_name    = docker_volume.drone-data.name
  }

  restart = "always"


  env = [
    "DRONE_GITEA_SERVER=https://git.cyber.psych0si.is",
    "DRONE_GITEA_CLIENT_ID=eb4b624b-0047-413a-921a-974f345b6835",
    "DRONE_GITEA_CLIENT_SECRET=gto_ijhta5ch3fqvezipi6lacsa4btuztb32zhf6nvx6blv77ertik7q",
    "DRONE_RPC_SECRET=super-duper-secret",
    "DRONE_SERVER_HOST=drone.apps.cyber.psych0si.is",
    "DRONE_SERVER_PROTO=http"
  ]

  ports {
    internal = 80
    external = 38259
  }

  #upload {
  #  file   = "/etc/kea/kea-dhcp4.conf"
  #  content = file("./kea/dhcp4.conf")
  #}

  #command = ["/entrypoint.sh", "-c", "/etc/kea/kea-dhcp4.conf"]
}


#resource "consul_service" "drone" {
#name  = "drone"
#node  = "snappy"
#port  = 38259
#check {
#  check_id = "drone-health-check"
#  name = "Drone Health check"
#  interval = "10s"
#  timeout = "2s"
#  http = "/"
#}

#  tags = ["traefik",
#    "traefik.enable=true",
#    "traefik.http.routers.drone.rule=Host(`drone.apps.cyber.psych0si.is`)",
#"traefik.http.routers.gitea.service=api@internal",
#    "traefik.http.routers.drone.entrypoints=http"
#  ]
#}
