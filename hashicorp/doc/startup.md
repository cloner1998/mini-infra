# Infrastructure Quick-Start Guide

This guide walks you through the step-by-step lifecycle of building your app image with Packer, spinning up the orchestrator mesh via Docker Compose, running the Nomad job, and verifying everything via Consul.

---

## Step 1: Build the Application Image (Packer)

Before booting up your orchestrators, you must build the immutable Docker image containing your Flask code. 

1. Navigate to your packer subdirectory:
   ```bash
   cd packer
2. Initialize the required Docker plugins for Packer:
   ```bash
   packer init app.pkr.hcl
   ```
3. Build the Docker image:
   ```bash
   packer build app.pkr.hcl
   ```
4. Return to the root directory:
   ```bash
   cd ..
   ```
Verification: Run `docker images | grep flask-nomad-app`. You should see flask-nomad-app:latest listed.

## Step 2: Spin Up Core Services (Docker Compose)
Now, launch the primary cluster backbone (Consul and Nomad) inside their shared network stack.
1. Start the containers in detached (background) mode:
   ```bash
   docker compose up -d
   ```
2. Verify that both containers are running stably:
   ```bash
   docker compose ps
   ```
Verification: Open your web browser and ensure you can hit the respective dashboards:

- Consul UI: http://localhost:8500 (http://127.0.0.1/:8500)
- Nomad UI: http://localhost:4646 (http://127.0.0.1/:4646)

## Step 3: Deploy the Workload (Nomad)
With the scheduler up and running, dispatch your Flask application job file directly into the Nomad cluster executor.
1. Submit the job file to the running Nomad container agent:
   ```bash
   docker exec mini-infra-nomad-1 nomad job run /jobs/flask-app.nomad
   ```
2. Check the real-time scheduling status of the job:
   ```bash
   docker exec mini-infra-nomad-1 nomad job status flask-app
   ```
Verification: Look at the Summary section in the status output. The Running counter under the web task group should
change from 0 to 1.

## Step 4: Verify Service Health & Routing (Consul)
Once Nomad provisions the allocation, it registers the service endpoint to Consul. Consul will immediately start
executing the HTTP /health probes.
1. Query Consul's catalog database via the CLI to check registered endpoints:
   ```bash
   docker exec mini-infra-consul-1 consul catalog services
   ```
   (You should see flask-app, nomad, and consul in the printed list).
2. View the health check details from your browser:
   - Navigate to http://localhost:8500/ui/dc1/services
   - Click on flask-app

Verification: The check status will turn green with a 200 OK code.

##  Tear-Down / Reset Commands
If you need to completely stop the environment, clean the states, or start fresh:
```bash
# 1. Stop and remove all running containers and networks
docker compose down

# 2. (Optional) Force wipe cached Docker volume networks if things get stuck
docker network prune -f
```
