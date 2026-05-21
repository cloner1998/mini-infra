job "flask-app" {
  datacenters = ["dc1"]
  type        = "service"

  group "web" {
    count = 1

    network {
      # 1. Define the port label here and set static to 5001
      port "http" {
        to = 5001
      }
    }

    task "flask" {
      driver = "docker"

      config {
        image      = "flask-nomad-app:v1.0.0"
        force_pull = false
        ports = ["http"]

        # 2. Force the Flask container to use the exact same network stack
        # as the active container running our Consul agent.
        network_mode = "container:mini-infra-consul-1"

        auth_soft_fail = true
      }

      resources {
        cpu    = 100
        memory = 128
      }

      service {
        name = "flask-app"
        port = "http"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.flask.rule=Path(`/`) || Path(`/health`)",
          "traefik.http.routers.flask.entrypoints=web",
          "traefik.http.services.flask.loadbalancer.server.port=5001"
        ]
        check {
          type     = "http"
          path     = "/health"
          interval = "10s"
          timeout  = "2s"
          address_mode = "driver"
        }
      }
    }
  }
}