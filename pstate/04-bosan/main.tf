# 問題番号

 variable "problem" {
    default = "04"
 }

 # vnc admin password
 variable "VNC_SERVER_PASSWORD" {
    default = "PUT_YOUR_PASSWORD_HERE"
 }

 # script
 resource sakuracloud_note "vnc-init" {
   name = "vnc-init"
   class = "shell"
   content = "${file("start.sh")}"
   description = "VNCサーバ(踏み台)初期化スクリプト"
 }

 # vnc archive
 data sakuracloud_archive "vnc-archive" {
    name_selectors = ["VNC", "IMG" , "V2"]
 }

 # switch
 resource sakuracloud_switch "vnc-switch" {
    name = "vnc-switch-${var.problem}"
 }

 # disks
 resource sakuracloud_disk "vnc-server-disk" {
    name              = "vnc-server-disk-${var.problem}"
    source_archive_id = "${data.sakuracloud_archive.vnc-archive.id}"
    note_ids          = ["${sakuracloud_note.vnc-init.id}"]
 }

 # servers
 resource sakuracloud_server "vnc-server" {
    name            = "vnc-server(踏み台)-${var.problem}"
    core            = 2
    memory          = 2
    disks           = ["${sakuracloud_disk.vnc-server-disk.id}"]
    nic             = "shared"
    additional_nics = ["${sakuracloud_switch.vnc-switch.id}"]
 }

 # output
 output "vnc_global_ip" {
    value = "${sakuracloud_server.vnc-server.ipaddress}"
 }

 ### ここから自由

 # switch

 resource sakuracloud_switch "04-bo_san-switch" {
     name = "04-bo_san-switch"
  }

 # Router1

 data sakuracloud_archive "04-bo_san-csr_Router1-archive" {
     name_selectors = ["2018-prep1-04-bo_san-csr_Router1"]
  }

  resource sakuracloud_disk "04-bo_san-csr_Router1-disk" {
     name              = "04-bo_san-csr_Router1"
     source_archive_id = "${data.sakuracloud_archive.04-bo_san-csr_Router1-archive.id}"
  }

  resource sakuracloud_server "bo_san-csr_Router1" {
     name            = "bo_san-csr_Router1"
     core            = 1
     memory          = 4
     disks           = ["${sakuracloud_disk.04-bo_san-csr_Router1-disk.id}"]
     nic             = "${sakuracloud_switch.vnc-switch.id}"
     additional_nics = ["${sakuracloud_switch.04-bo_san-switch.id}"]
  }

 # Router2

 data sakuracloud_archive "04-bo_san-vyos_Router2-archive" {
     name_selectors = ["2018-prep1-04-bo_san-vyos_Router2"]
  }

  resource sakuracloud_disk "04-bo_san-vyos_Router2-disk" {
     name              = "04-bo_san-vyos_Router2"
     source_archive_id = "${data.sakuracloud_archive.04-bo_san-vyos_Router2-archive.id}"
  }

  resource sakuracloud_server "bo_san-vyos_Router2" {
     name            = "bo_san-vyos_Router2"
     core            = 1
     memory          = 1
     disks           = ["${sakuracloud_disk.04-bo_san-vyos_Router2-disk.id}"]
     nic             = "${sakuracloud_switch.04-bo_san-switch.id}"
  }