job "postgres" {
  datacenters = ["dc1"]
  type = "service"

  group "db" {
    count = 1

    network {
      port "db" {
        to     = 5432
        static = 5432
      }
    }

    task "postgres" {
      driver = "docker"

      config {
        image          = "docker.ibcbridgeai.org/library/postgres:17"
        force_pull     = false
        auth_soft_fail = true
        ports = ["db"]
        network_mode   = "container:mini-infra-consul-1"
      }

      env {
        POSTGRES_DB       = "flaskdb"
        POSTGRES_USER     = "flask"
        POSTGRES_PASSWORD = "secret123"
      }

      resources {
        cpu    = 200
        memory = 256
      }
      service {
        name = "postgres"
        port = "db"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}