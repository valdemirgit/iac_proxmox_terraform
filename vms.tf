resource "proxmox_vm_qemu" "ubuntuteste" {

  name        = "K8s.ubuntu"
  target_node = "pveteste"
  vmid        = "102"
  iso         = "local:ubuntu-24.04-desktop-amd64.iso"

  agent = 0

  cores   = 2
  sockets = 2
  cpu     = "host"
  memory  = 4096

  os_type = "ubuntu"
  pxe     = "false"


  network {
    bridge = "vmbr0"
    model  = "virtio"
  }

  network {
    bridge = "vmbr1"
    model  = "virtio"
  }
  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = 30
        }
      }



    }
  }
}