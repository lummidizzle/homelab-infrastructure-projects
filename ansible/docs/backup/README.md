# Backup Server Role Configuration (backup.corp.local)

## Overview

This document describes the Ansible role for configuring and automating backups across the lab environment. The backup server uses `rsync`, `logrotate`, and `cron` to create secure, scheduled backups of critical VMs and configuration files to a centralized location.

## Server Information

- **Hostname:** backup.corp.local
- **IP Address:** 192.168.1.16
- **Operating System:** RHEL 9
- **Ansible Role Directory:** `ansible/roles/backup`
- **Backup Target Server:** `HP2-DESKTOP` (central depot)

## Goals of the Backup Role

- Automate rsync-based backups of critical directories and VMs
- Enable timestamped folder structure for versioned backups
- Compress and rotate logs of backup tasks using logrotate
- Schedule daily or weekly backups using crontab
- Protect against accidental VM loss or data corruption

## Role Structure

```bash
ansible/
├── roles/
│   └── backup/
│       ├── tasks/
│       │   └── main.yml
│       ├── templates/
│       │   └── backup-script.sh.j2
│       └── files/
│           └── logrotate-backup

