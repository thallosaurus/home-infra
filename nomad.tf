resource "nomad_job" "job_a" {
  jobspec = file("${path.module}/jobs/demo.hcl")
  hcl2 {
    allow_fs = true
  }
}

resource "nomad_job" "vpn" {
  jobspec = file("${path.module}/jobs/vpn.hcl")
  hcl2 {
    allow_fs = true
  }
}

resource "nomad_job" "network" {
  jobspec = file("${path.module}/jobs/network.hcl")
  hcl2 {
    allow_fs = true
  }
}

resource "nomad_job" "metube" {
  jobspec = file("${path.module}/jobs/metube.hcl")
  hcl2 {
    allow_fs = true
  }
}

resource "nomad_job" "monitor" {
  jobspec = file("${path.module}/jobs/monitor.hcl")
  hcl2 {
    allow_fs = true
  }
}

resource "nomad_job" "traefik" {
  jobspec = file("${path.module}/jobs/traefik.hcl")
  hcl2 {
    allow_fs = true
  }
}

resource "nomad_job" "homeassistant" {
  jobspec = file("${path.module}/jobs/homeassistant.hcl")
  hcl2 {
    allow_fs = true
  }
}

resource "nomad_job" "cloudflared" {
  jobspec = file("${path.module}/jobs/cloudflared.hcl")
  hcl2 {
    allow_fs = true
  }
}

resource "nomad_job" "samba" {
  jobspec = file("${path.module}/jobs/samba.hcl")
  hcl2 {
    allow_fs = true
  }
}
