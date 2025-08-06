# Monitoring Server Setup and Configuration (monitoring.corp.local)

## Overview

This documentation outlines the installation, configuration, and Ansible role setup for the Monitoring Server in the homelab environment. The monitoring server is responsible for observing the health, availability, and performance of all critical servers using **Nagios Core**. Additional tools such as log aggregation, service checks, and email alerting will be incorporated in future phases.

## Server Information

- **Hostname:** monitoring.corp.local
- **IP Address:** 192.168.1.15
- **Operating System:** RHEL 9
- **Assigned Role:** Monitoring Server
- **Ansible Role Directory:** `ansible/roles/monitoring`

## Goals of the Monitoring Role

- Install and configure **Nagios Core** and necessary plugins.
- Monitor all essential services (SSH, HTTP, disk usage, CPU, memory).
- Enable web interface with authentication for viewing alerts.
- Automate host and service configuration using Ansible templates.

## Ansible Structure

```bash
ansible/
├── roles/
│   └── monitoring/
│       ├── tasks/
│       │   └── main.yml
│       ├── templates/
│       │   ├── nagios.cfg.j2
│       │   ├── cgi.cfg.j2
│       │   └── hosts.cfg.j2
│       └── files/
│           └── htpasswd.users

