job "gitea" {
  type = "service"

  group "gitea" {
    network {
      port "http" {
        to     = "3000"
        static = "3456"
      }

      port "ssh" {
        to     = "22"
        static = "2222"
      }
    }

    service {
      name = "gitea"
      port = "http"
      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.gitea.rule=(Host(`gitea.apps.cyber.psych0si.is`) || Host(`git.cyber.psych0si.is`)) && PathPrefix(`/`)",
        "traefik.http.routers.gitea.entrypoints=http,public",
      ]
      #provider = "nomad"

      check {
        name     = "Gitea Frontend Check"
        path     = "/api/healthz"
        type     = "http"
        protocol = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    volume "data" {
      type            = "csi"
      read_only       = false
      source          = "nfs_gitea"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    task "gitea" {
      driver = "docker"

      template {
        destination = "local/app.ini"
        data        = <<EOH
{{- with nomadVar "nomad/jobs/gitea" -}}
APP_NAME = cyber.psych0si.is
RUN_MODE = prod
RUN_USER = git
WORK_PATH = /data/gitea

[repository]
ROOT = /data/git/repositories

[repository.local]
LOCAL_COPY_PATH = /data/gitea/tmp/local-repo

[repository.upload]
TEMP_PATH = /data/gitea/uploads

[server]
APP_DATA_PATH = /data/gitea
DOMAIN = gitea.apps.cyber.psych0si.is
SSH_DOMAIN = ssh.git.cyber.psych0si.is
HTTP_PORT = 3000
ROOT_URL = http://gitea.apps.cyber.psych0si.is/
DISABLE_SSH = true
SSH_PORT = 22
SSH_LISTEN_PORT = 22
LFS_START_SERVER = true
LFS_JWT_SECRET = {{ .lfs_jwt_secret }}
OFFLINE_MODE = true

[database]
PATH = /data/gitea/gitea.db
DB_TYPE = sqlite3
HOST = localhost:3306
NAME = gitea
USER = root
PASSWD = 
LOG_SQL = false
SCHEMA = 
SSL_MODE = disable

[indexer]
ISSUE_INDEXER_PATH = /data/gitea/indexers/issues.bleve

[session]
PROVIDER_CONFIG = /data/gitea/sessions
PROVIDER = file

[picture]
AVATAR_UPLOAD_PATH = /data/gitea/avatars
REPOSITORY_AVATAR_UPLOAD_PATH = /data/gitea/repo-avatars

[attachment]
PATH = /data/gitea/attachments

[log]
MODE = console
LEVEL = info
ROOT_PATH = /data/gitea/log

[security]
INSTALL_LOCK = true
SECRET_KEY = 
REVERSE_PROXY_LIMIT = 1
REVERSE_PROXY_TRUSTED_PROXIES = *
INTERNAL_TOKEN = {{ .internal_token }}
PASSWORD_HASH_ALGO = pbkdf2

[service]
DISABLE_REGISTRATION = true
REQUIRE_SIGNIN_VIEW = false
REGISTER_EMAIL_CONFIRM = false
ENABLE_NOTIFY_MAIL = false
ALLOW_ONLY_EXTERNAL_REGISTRATION = false
ENABLE_CAPTCHA = false
DEFAULT_KEEP_EMAIL_PRIVATE = true
DEFAULT_ALLOW_CREATE_ORGANIZATION = true
DEFAULT_ENABLE_TIMETRACKING = true
NO_REPLY_ADDRESS = noreply.localhost

[lfs]
PATH = /data/git/lfs

[mailer]
ENABLED = false

[openid]
ENABLE_OPENID_SIGNIN = true
ENABLE_OPENID_SIGNUP = true

[cron.update_checker]
ENABLED = false

[repository.pull-request]
DEFAULT_MERGE_STYLE = merge

[repository.signing]
DEFAULT_TRUST_MODEL = committer

[oauth2]
JWT_SECRET = {{ .oauth2_jwt_secret }}
{{- end -}}
      EOH
      }

      volume_mount {
        volume      = "data"
        destination = "/data"
        read_only   = false
      }


      config {
        image = "gitea/gitea"
        ports = ["http"]
        privileged = true
        mount {
          type     = "bind"
          source   = "local/app.ini"
          target   = "/data/gitea/conf/app.ini"
          readonly = true
        }
      }
    }
  }
}