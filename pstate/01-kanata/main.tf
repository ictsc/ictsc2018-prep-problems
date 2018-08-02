# 問題番号
 variable "problem" {
    default = "01-kanata"
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

 ### 以下自由に書く

## archives

data sakuracloud_archive "prep1-01-kanata_archive_1" {
  name_selectors = ["2018-prep1-01-kanata_01"]
}

data sakuracloud_archive "prep1-01-kanata_archive_2" {
  name_selectors = ["2018-prep1-01-kanata_02"]
}

data sakuracloud_archive "prep1-01-kanata_archive_3" {
  name_selectors = ["2018-prep1-01-kanata_03"]
}

## disks

resource sakuracloud_disk "prep1-01-kanata_disk_01" {
  name              = "prep1-01-kanata_01"
  hostname          = "kube01"
  password          = "kubernetes"
  source_archive_id = "${data.sakuracloud_archive.prep1-01-kanata_archive_1.id}"
}

resource sakuracloud_disk "prep1-01-kanata_disk_02" {
  name              = "prep1-01-kanata_02"
  hostname          = "kube02"
  password          = "kubernetes"
  source_archive_id = "${data.sakuracloud_archive.prep1-01-kanata_archive_2.id}"
}

resource sakuracloud_disk "prep1-01-kanata_disk_03" {
  name              = "prep1-01-kanata_03"
  hostname          = "kube03"
  password          = "kubernetes"
  source_archive_id = "${data.sakuracloud_archive.prep1-01-kanata_archive_3.id}"
}

## servers

resource sakuracloud_server "prep1-01-kanata_1" {
  name            = "prep1-01-kanata_01"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.prep1-01-kanata_disk_01.id}"]
  nic             = "${sakuracloud_switch.vnc-switch.id}"
  ipaddress       = "192.168.0.1"
  nw_mask_len     = "24"
  gateway         = "192.168.0.254"
}

resource sakuracloud_server "prep1-01-kanata_2" {
  name            = "prep1-01-kanata_02"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.prep1-01-kanata_disk_02.id}"]
  nic             = "${sakuracloud_switch.vnc-switch.id}"
  ipaddress       = "192.168.0.2"
  nw_mask_len     = "24"
  gateway         = "192.168.0.254"
}

resource sakuracloud_server "prep1-01-kanata_3" {
  name            = "prep1-01-kanata_03"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.prep1-01-kanata_disk_03.id}"]
  nic             = "${sakuracloud_switch.vnc-switch.id}"
  ipaddress       = "192.168.0.3"
  nw_mask_len     = "24"
  gateway         = "192.168.0.254"
}
