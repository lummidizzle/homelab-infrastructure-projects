# dns-nfs (RHEL 9) — DNS + NFSv4 + Logging Hub

**Hostname:** dns-nfs.corp.local  
**IP Address:** 192.168.1.14  
**Role:** Caching/forwarding DNS (Unbound) + NFSv4 exports (`/shared`, `/tools`, `/logs`) and central log storage  
**Storage:** 150 GB VMDK mounted at `/srv/nfs` (XFS, label: `NFSDATA`)  
**Retention:** Daily rotation, keep 3 days, compress

---

## Architecture

- **Unbound** forwards:
  - `corp.local` → `192.168.1.137` (AD DNS / WS2022-DC)
  - Everything else → `1.1.1.1`, `8.8.8.8`
- **NFSv4 root** at `/srv/nfs` (`fsid=0`, `crossmnt`), exports:
  - `/srv/nfs/shared` (rw) — shared space
  - `/srv/nfs/tools`  (ro) — read-only tools/isos
  - `/srv/nfs/logs`   (rw) — central logs for syslog server
- **Firewall:** `dns`, `nfs`, `ssh` services allowed
- **SELinux:** Enforcing (defaults under `/srv` work)

---

## Build Notes (commands used)

### Disk & mount (150 GB at /srv/nfs)
```bash
sudo parted -s /dev/nvme0n2 mklabel gpt mkpart primary xfs 1MiB 100%
sudo mkfs.xfs -L NFSDATA /dev/nvme0n2p1
sudo mkdir -p /srv/nfs/{shared,tools,logs}
echo 'LABEL=NFSDATA  /srv/nfs  xfs  defaults,noatime  0 0' | sudo tee -a /etc/fstab
sudo mount -a

## Install & configure Unbound

sudo dnf install -y unbound
sudo tee /etc/unbound/unbound.conf <<EOC
server:
    interface: 0.0.0.0
    access-control: 192.168.1.0/24 allow
    do-ip4: yes
    do-udp: yes
    do-tcp: yes
    hide-identity: yes
    hide-version: yes
    harden-glue: yes
    harden-dnssec-stripped: yes
    use-caps-for-id: yes

forward-zone:
    name: "corp.local"
    forward-addr: 192.168.1.137

forward-zone:
    name: "."
    forward-addr: 1.1.1.1
    forward-addr: 8.8.8.8
EOC
sudo systemctl enable --now unbound

## Install & configure NFSv4

sudo dnf install -y nfs-utils
sudo tee /etc/exports <<EOC
/srv/nfs      192.168.1.0/24(rw,sync,fsid=0,crossmnt)
/srv/nfs/shared 192.168.1.0/24(rw,sync,no_subtree_check)
/srv/nfs/tools  192.168.1.0/24(ro,sync,no_subtree_check)
/srv/nfs/logs   192.168.1.0/24(rw,sync,no_subtree_check)
EOC
sudo exportfs -rav
sudo systemctl enable --now nfs-server


## Firewall

sudo firewall-cmd --permanent --add-service=dns
sudo firewall-cmd --permanent --add-service=nfs
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload


## Logrotate policy for /srv/nfs/logs

sudo tee /etc/logrotate.d/nfs-logs <<EOC
/srv/nfs/logs/*.log {
    daily
    rotate 3
    compress
    missingok
    notifempty
    create 0640 root root
}
EOC



