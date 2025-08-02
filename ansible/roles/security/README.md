# Ansible Role: Security

This Ansible role provides baseline security hardening for Linux systems by:

- Installing and enabling UFW (Debian/Ubuntu only)
- Installing and enabling Auditd (RHEL & Debian)
- Installing and configuring AIDE for file integrity checks
- Using OS-specific `aide.conf` configurations

## 🔧 Features

| Feature | Description |
|--------|-------------|
| UFW     | Configures uncomplicated firewall on Debian systems |
| Auditd  | Enables system auditing for compliance and event logging |
| AIDE    | Detects file changes, permissions tampering, and suspicious modifications |

## 🏗️ File Structure

```bash
roles/security/
├── files/
│   ├── aide.conf.debian
│   └── aide.conf.redhat
├── tasks/
│   └── main.yml
└── README.md

