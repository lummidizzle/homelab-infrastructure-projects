# Syslog Server Configuration (syslog.corp.local)

## Overview

This documentation covers the installation, configuration, and Ansible role implementation for the central syslog server in the homelab environment. The syslog server consolidates system logs from all other servers, improving auditability, security, and troubleshooting.

## Server Information

- **Hostname:** syslog.corp.local
- **IP Address:** 192.168.1.17
- **Operating System:** RHEL 9
- **Primary Service:** rsyslog
- **Log Retention:** 90 days (via `logrotate`)
- **Ansible Role Directory:** `ansible/roles/syslog`

## Goals of the Syslog Role

- Install and configure `rsyslog` to receive logs from all remote hosts
- Enable persistent logging to structured directories (e.g., `/var/log/hosts/`)
- Implement secure log rotation using `logrotate`
- Maintain 90-day retention with compression after 7 days

## Ansible Role Structure

```bash
ansible/
├── roles/
│   └── syslog/
│       ├── tasks/
│       │   └── main.yml
│       ├── templates/
│       │   └── rsyslog.conf.j2
│       │   └── 10-remotelog.conf.j2
│       └── files/
│           └── logrotate_syslog

