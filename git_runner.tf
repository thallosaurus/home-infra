resource "docker_image" "act_runner" {
  name = "gitea/act_runner:latest"
}

resource "docker_container" "runner01" {
  count = 0
  name  = "act_runner"
  image = docker_image.act_runner.image_id

  network_mode = "bridge"

  upload {
    file    = "/config.yaml"
    content = file("./runner/config.yaml")
  }

  env = [
    "CONFIG_FILE=/config.yaml",
    "GITEA_INSTANCE_URL=https://git.cyber.psych0si.is",
    "GITEA_RUNNER_NAME=test",
    "GITEA_RUNNER_REGISTRATION_TOKEN=${data.nomad_variable.runner_token.items["gitea_token01"]}"
  ]

  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
  }
}

#data "nomad_job" "gitea" {
#    job_id = "gitea"
#}

#data "vault_generic_secret" "gitea_secrets" {
#  path = "kv/gitea_runner"
#}

data "nomad_variable" "runner_token" {
  path  = "nomad/jobs"
}