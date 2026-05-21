plugin "docker" {
  config {
    endpoint = "unix:///var/run/docker.sock"

    pull_activity_timeout = "5m"
    allow_privileged = true

    volumes {
      enabled = true
    }


    # never pull, use local images only
    disable_log_collection = false

    extra_labels = ["job_name", "task_group_name", "task_name"]

  }
}