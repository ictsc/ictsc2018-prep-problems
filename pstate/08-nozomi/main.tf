# 問題番号
 variable "problem" {
    default = "08"
 }

# チーム番号
 variable "TEAM_LOGIN_ID" {
    default = "PUT_TEAM_NUMBER_HERE"
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


 resource sakuracloud_note "vnc-webrtc" {
   name = "vnc-webrtc"
   class = "shell"
   content = "${file("vnc.sh")}"
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
    note_ids          = ["${sakuracloud_note.vnc-init.id}","${sakuracloud_note.vnc-webrtc.id}"]
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

 ### 以下自由に書く

  data sakuracloud_archive "08-server-archive" {
     name_selectors = ["2018-prep1-08-server"]
  }

  resource sakuracloud_disk "08-server-disk" {
     name              = "08-server"
     source_archive_id = "${data.sakuracloud_archive.08-server-archive.id}"
  }

  resource sakuracloud_server "08-server-server" {
     name            = "08-server-server"
     core            = 1
     memory          = 1
     disks           = ["${sakuracloud_disk.08-server-disk.id}"]
     nic             = "${sakuracloud_switch.vnc-switch.id}"
  }
