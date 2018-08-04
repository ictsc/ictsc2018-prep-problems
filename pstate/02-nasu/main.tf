# 問題番号
 variable "problem" {
    default = "02"
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

 ### 以下自由に書く

## archives

data sakuracloud_archive "02-zabbix-archive" {
  name_selectors = ["2018-prep1-02-zabbix"]
}

data sakuracloud_archive "02-grafana-archive" {
  name_selectors = ["2018-prep1-02-grafana"]
}

data sakuracloud_archive "02-snmp-archive" {
  name_selectors = ["2018-prep1-02-snmp"]
}

## script_for_vyos
resource "sakuracloud_note" "02-snmp-script" {
  name        = "02-snmp-script"
  class       = "shell"
  content     = "${file("vyos.sh")}"
}

## disks

resource sakuracloud_disk "02-zabbix-disk" {
  name              = "02-zabbix-disk"
  source_archive_id = "${data.sakuracloud_archive.02-zabbix-archive.id}"  
}

resource sakuracloud_disk "02-grafana-disk" {
  name              = "02-grafana-disk"
  source_archive_id = "${data.sakuracloud_archive.02-grafana-archive.id}"  
}

resource sakuracloud_disk "02-snmp-disk" {
  name              = "02-snmp-disk"
  source_archive_id = "${data.sakuracloud_archive.02-snmp-archive.id}"  
  note_ids          = ["${sakuracloud_note.02-snmp-script.id}"] 

}
## servers
resource sakuracloud_server "02-zabbix-server" {
  name            = "02-zabbix-server"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.02-zabbix-disk.id}"]
  nic             = "${sakuracloud_switch.vnc-switch.id}"
}

resource sakuracloud_server "02-grafana-server" {
  name            = "02-grafana-server"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.02-grafana-disk.id}"]
  nic             = "${sakuracloud_switch.vnc-switch.id}"
}


resource sakuracloud_server "02-snmp-server" {
  name            = "02-snmp-server"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.02-snmp-disk.id}"]
  nic             = "${sakuracloud_switch.vnc-switch.id}"
}





