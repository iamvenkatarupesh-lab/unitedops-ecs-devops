# Phase 1: Local Baseline

## What We Are Doing

We are creating a small airline operations platform that can run locally before it runs in AWS.

## Why We Are Doing It

DevOps is not only cloud deployment. A good DevOps engineer first makes the application repeatable and testable in a local environment. This gives us a known-good baseline before Docker, ECS, Terraform, and CI/CD enter the picture.

## Concepts

- **Service boundary**: each backend service has one responsibility.
- **Health endpoint**: infrastructure needs a simple way to know whether a service is alive.
- **Environment variables**: configuration changes between local, CI, and AWS without changing code.
- **Docker Compose**: local orchestration for multiple containers.

## Interview Explanation

You can say:

> I started by creating a local baseline with independent services and health endpoints. This made it easier to containerize, test, and later deploy each service to ECS behind an Application Load Balancer.

## Verification

After dependencies are installed, run:

```bash
npm install
npm run dev:flight
curl http://localhost:4001/health
```

For Docker Compose:

```bash
docker compose up --build
curl http://localhost:4001/health
curl http://localhost:4002/health
curl http://localhost:4003/health
curl http://localhost:4004/health
```
