## Mini Infrastructure

A local infrastructure lab demonstrating a deployment workflow built with Packer, Nomad, Consul, and Docker Compose.

## Overview
The project builds an immutable Docker image for a Flask application, starts a local orchestration environment, deploys the application through Nomad, and registers it with Consul for service discovery and health checking.

Stack
Docker & Docker Compose
Packer
Nomad
Consul
Flask
Project Structure
```text
.
├── docs/           # Project documentation
├── packer/         # Packer templates
├── jobs/           # Nomad job specifications
├── app/            # Flask application
├── docker-compose.yml
└── README.md
```
---
## Prerequisites
- Docker
- Docker Compose
- Packer
- See docs/ for installation instructions.
---

## Quick Start
1. Build the application image
```bash
cd packer
packer init app.pkr.hcl
packer build app.pkr.hcl
cd ..
```
2. Start the infrastructure
```bash
docker compose up -d
```
3. Deploy the application
```bash
docker exec mini-infra-nomad-1 nomad job run /jobs/flask-app.nomad
```
5. Verify

- Nomad UI: `http://localhost:4646`
- Consul UI `http://localhost:8500`
- Traefik UI `http://localhost:8080`
- RabbitMQ UI `http://localhost:15672`
---
## Documentation

Additional documentation is available in the docs/ directory:
Architecture overview
Packer installation
Docker-in-Docker explanation
Networking
Infrastructure lifecycle
Troubleshooting

---
## License

MIT
