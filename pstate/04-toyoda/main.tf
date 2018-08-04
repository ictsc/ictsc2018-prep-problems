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
    name_selectors = ["VNC", "IMG" , "V3"]
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

 resource sakuracloud_switch "04-toyoda-switch" {
     name = "04-toyoda-switch"
  }

 # Router-A

 data sakuracloud_archive "04-toyoda-Router-A-archive" {
     name_selectors = ["2018-prep1-04-toyoda-Router-A"]
  }

  resource sakuracloud_disk "04-toyoda-Router-A-disk" {
     name              = "04-toyoda-Router-A"
     source_archive_id = "${data.sakuracloud_archive.04-toyoda-Router-A-archive.id}"
  }

  resource sakuracloud_server "toyoda-Router-A" {
     name            = "toyoda-Router-A"
     core            = 1
     memory          = 4
     disks           = ["${sakuracloud_disk.04-toyoda-Router-A-disk.id}"]
     nic             = "${sakuracloud_switch.vnc-switch.id}"
     additional_nics = ["${sakuracloud_switch.04-toyoda-switch.id}"]
  }

 # Router-B

 data sakuracloud_archive "04-toyoda-Router-B-archive" {
     name_selectors = ["2018-prep1-04-toyoda-Router-B"]
  }

  resource sakuracloud_disk "04-toyoda-Router-B-disk" {
     name              = "04-toyoda-Router-B"
     source_archive_id = "${data.sakuracloud_archive.04-toyoda-Router-B-archive.id}"
  }

  resource sakuracloud_server "toyoda-Router-B" {
     name            = "toyoda-Router-B"
     core            = 1
     memory          = 1
     disks           = ["${sakuracloud_disk.04-toyoda-Router-B-disk.id}"]
     nic             = "${sakuracloud_switch.vnc-switch.id}"
     additional_nics = ["${sakuracloud_switch.04-toyoda-switch.id}"]
  }