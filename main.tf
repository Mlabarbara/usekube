terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://192.168.11.1:8006/api2/json"
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = true
}

resource "proxmox_vm_qemu" "kube-server" {
  count       = 1
  name        = "kube-server-0${count.index + 1}"
  target_node = "r630-pve"
  vmid        = "100${count.index + 1}"

  clone = "ubuntu-2004-cloudinit-template"

  agent    = 1
  os_type  = "cloud-init"
  cores    = 2
  sockets  = 1
  cpu      = "host"
  memory   = 4096
  scsihw   = "virtio-scsi-single"
  bootdisk = "scsi0"

  disk {
    slot     = 0
    size     = "10G"
    type     = "scsi"
    storage  = "nvme001"
    iothread = 1
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  network {
    model  = "virtio"
    bridge = "vmbr17"
  }

  ipconfig0 = "ip=192.168.11.20${count.index + 1}/16,gw=192.168.10.1"
  ipconfig1 = "ip=10.17.0.4${count.index + 1}/24"
  sshkeys   = var.ssh_key
}
resource "proxmox_vm_qemu" "kube-agent" {
  count       = 2
  name        = "kube-agent-0${count.index + 1}"
  target_node = "r630-pve"
  vmid        = "50${count.index + 1}"

  clone = "ubuntu-2004-cloudinit-template"

  agent    = 1
  os_type  = "cloud-init"
  cores    = 2
  sockets  = 1
  cpu      = "host"
  memory   = 4096
  scsihw   = "virtio-scsi-single"
  bootdisk = "scsi0"

  disk {
    slot     = 0
    size     = "10G"
    type     = "scsi"
    storage  = "nvme001"
    iothread = 1
  }
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  network {
    model  = "virtio"
    bridge = "vmbr17"
  }

  ipconfig0 = "ip=192.168.11.10${count.index + 1}/26,gw=192.168.10.1"
  ipconfig1 = "ip=10.17.0.5${count.index + 1}/24"
  sshkeys   = var.ssh_key
}
