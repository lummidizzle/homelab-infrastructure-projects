# templates directory
# templates/

Jinja2 templates for configuration files.

- `motd.j2` – dynamic login banner.
- `sshd_config.j2` – hardened SSH config with vars:
  - `sshd_port` (default `22`)
  - `sshd_permit_root` (default `no`)
  - `sshd_password_auth` (default `no`)

