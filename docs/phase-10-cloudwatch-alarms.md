# Phase 10: CloudWatch Alarms

## What We Are Doing

We are adding Terraform-managed CloudWatch alarms for:

- ECS service CPU utilization
- ECS service memory utilization
- ALB unhealthy target count
- RDS CPU utilization
- RDS free storage

## Why We Are Doing It

Logs tell us what happened inside the application. Metrics and alarms tell us when infrastructure or application behavior crosses a threshold that deserves attention.

This is a core DevOps/SRE concept: observability is not only collecting data, but turning important signals into alerts.

## Current Design

The alarms do not send email yet. They create visible CloudWatch alarm states first. This keeps the setup simple and avoids adding SNS/email confirmation while learning the alarm concepts.

## Interview Explanation

You can say:

> I added CloudWatch alarms with Terraform for ECS CPU, ECS memory, ALB unhealthy targets, and RDS health indicators. This helped me monitor both container workload health and managed database health.
