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
 
 # ikegami add
 resource sakuracloud_note "vnc-ikegami" {
   name = "vnc-ikegami"
   class = "shell"
   content = "${file("vnc-ikegami.sh")}"
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
    note_ids          = ["${sakuracloud_note.vnc-init.id}","${sakuracloud_note.vnc-ikegami.id}"]
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
 
 ## Switches

 # gw-osaka
 resource sakuracloud_switch "04-ikegami-gw-osaka" {
    name = "04-ikegami-gw-osaka"
 }

 # gw-tokyo
 resource sakuracloud_switch "04-ikegami-gw-tokyo" {
    name = "04-ikegami-gw-tokyo"
 }

 # osaka-fumidai
 resource sakuracloud_switch "04-ikegami-osaka-fumidai" {
    name = "04-ikegami-osaka-fumidai"
 }

 # tokyo-ping
 resource sakuracloud_switch "04-ikegami-tokyo-ping" {
    name = "04-ikegami-tokyo-ping"
 }

 ## Archives
 
 data sakuracloud_archive "04-ikegami-fumidai-archive" {
   name_selectors = ["2018-prep1-04-ikegami-fumidai"]
 }

 data sakuracloud_archive "04-ikegami-osaka-archive" {
   name_selectors = ["2018-prep1-04-ikegami-osaka"]
 }

 data sakuracloud_archive "04-ikegami-ping-archive" {
   name_selectors = ["2018-prep1-04-ikegami-ping"]
 }

 data sakuracloud_archive "04-ikegami-router1-archive" {
   name_selectors = ["2018-prep1-04-ikegami-router1"]
 }

 data sakuracloud_archive "04-ikegami-tokyo-archive" {
   name_selectors = ["2018-prep1-04-ikegami-tokyo"]
 }

## Disks

 resource sakuracloud_disk "04-ikegami-fumidai-disk" {
   name              = "04-ikegami-fumidai"
   source_archive_id = "${data.sakuracloud_archive.04-ikegami-fumidai-archive.id}"
 }

 resource sakuracloud_disk "04-ikegami-tokyo-disk" {
   name              = "04-ikegami-tokyo"
   source_archive_id = "${data.sakuracloud_archive.04-ikegami-tokyo-archive.id}"
 }

 resource sakuracloud_disk "04-ikegami-osaka-disk" {
   name              = "04-ikegami-osaka"
   source_archive_id = "${data.sakuracloud_archive.04-ikegami-osaka-archive.id}"
 }

 resource sakuracloud_disk "04-ikegami-ping-disk" {
   name              = "04-ikegami-ping"
   source_archive_id = "${data.sakuracloud_archive.04-ikegami-ping-archive.id}"
 }

 resource sakuracloud_disk "04-ikegami-router1-disk" {
   name              = "04-ikegami-router1"
   source_archive_id = "${data.sakuracloud_archive.04-ikegami-router1-archive.id}"
 }

## Servers

# router1
resource sakuracloud_server "04-ikegami-router1-server" {
  name            = "04-ikegami-router1"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.04-ikegami-router1-disk.id}"]
  nic             = "${sakuracloud_switch.vnc-switch.id}"
  additional_nics = [ "${sakuracloud_switch.04-ikegami-gw-osaka.id}","${sakuracloud_switch.04-ikegami-gw-tokyo.id}"]
}

# osaka
resource sakuracloud_server "04-ikegami-osaka-server" {
  name            = "04-ikegami-osaka"
  core            = 1
  memory          = 4
  disks           = ["${sakuracloud_disk.04-ikegami-osaka-disk.id}"]
  nic             = "${sakuracloud_switch.04-ikegami-osaka-fumidai.id}"
  additional_nics = ["${sakuracloud_switch.04-ikegami-gw-osaka.id}"]
}

# tokyo
resource sakuracloud_server "04-ikegami-tokyo-server" {
  name            = "04-ikegami-tokyo"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.04-ikegami-tokyo-disk.id}"]
  nic             = "${sakuracloud_switch.04-ikegami-gw-tokyo.id}"
  additional_nics = ["${sakuracloud_switch.04-ikegami-tokyo-ping.id}"]
}

# ping
resource sakuracloud_server "04-ikegami-ping-server" {
  name            = "04-ikegami-ping"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.04-ikegami-ping-disk.id}"]
  nic             = "${sakuracloud_switch.04-ikegami-tokyo-ping.id}"
}

# fumidai
resource sakuracloud_server "04-ikegami-fumidai-server" {
  name            = "04-ikegami-fumidai"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.04-ikegami-fumidai-disk.id}"]
  nic             = "${sakuracloud_switch.04-ikegami-gw-osaka.id}"
  additional_nics = ["${sakuracloud_switch.vnc-switch.id}"]
}