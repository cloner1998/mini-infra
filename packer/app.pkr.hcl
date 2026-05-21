packer {
  required_plugins {
    docker = {
      source  = "github.com/hashicorp/docker"
      version = "~> 1"
    }
  }
}

source "docker" "flask" {
  image  = "python:3.11-slim"
  commit = true
  changes = [
    "EXPOSE 5001",
    "CMD [\"python\", \"/app/app.py\"]"
  ]
}

build {
  sources = ["source.docker.flask"]

  provisioner "file" {
    source      = "./app"
    destination = "/"
  }

  provisioner "shell" {
    inline = [
      "pip install -r /app/requirements.txt"
    ]
  }

  post-processors {
    post-processor "docker-tag" {
      repository = "flask-nomad-app"
      tags       = ["v2.0.0"]
    }
  }
}