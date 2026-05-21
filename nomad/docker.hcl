plugin "docker" {
  config {
    endpoint = "unix:///var/run/docker.sock"

    pull_activity_timeout = "5m"

  }
}