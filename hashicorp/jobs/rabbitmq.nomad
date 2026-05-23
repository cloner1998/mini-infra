job "rabbitmq" {
  datacenters = ["dc1"]
  type = "service"

  group "queue" {
    count = 1

    network {
      port "amqp" {
        to     = 5672
        static = 5672    # messaging port
      }
      port "ui" {
        to     = 15672
        static = 15672   # management UI port
      }
    }

    task "rabbitmq" {
      driver = "docker"

      config {
        image          = "docker.ibcbridgeai.org/library/rabbitmq:3-management"
        force_pull     = false
        auth_soft_fail = true
        ports = ["amqp", "ui"]
        network_mode   = "container:mini-infra-consul-1"
      }

      env {
        RABBITMQ_DEFAULT_USER  = "admin"
        RABBITMQ_DEFAULT_PASS  = "secret123"
        RABBITMQ_DEFAULT_VHOST = "/"
      }

      resources {
        cpu    = 300
        memory = 512
      }

      service {
        name = "rabbitmq"
        port = "amqp"
        tags = ["queue"]


        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      service {
        name = "rabbitmq-ui"

        port = "ui"
        #address_mode = "driver"
        tags = [
          "traefik.enable=true",
          # 1. Using a unified router identifier: rabbitmq-ui
          "traefik.http.routers.rabbitmq-ui.rule=PathPrefix(`/rabbitmq`)",
          "traefik.http.routers.rabbitmq-ui.entrypoints=web",

          # 2. Binding the router explicitly to our custom service definition name
          "traefik.http.routers.rabbitmq-ui.service=rabbitmq-ui-backend",

          # 3. FIXED: The service name here now perfectly matches the line above
          "traefik.http.services.rabbitmq-ui-backend.loadbalancer.server.port=15672"
        ]

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}