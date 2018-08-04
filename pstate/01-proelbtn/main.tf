# 問題番号
variable "problem" {
default = "01"
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

resource sakuracloud_switch "01-proelbtn-local" {
 name = "01-proelbtn-local"
}

data sakuracloud_archive "01-proelbtn-router-archive" {
 name_selectors = ["2018-prep1-01-proelbtn-router"]
}

data sakuracloud_archive "01-proelbtn-server-archive" {
 name_selectors = ["2018-prep1-01-proelbtn-server"]
}

resource sakuracloud_disk "01-proelbtn-router-disk" {
 name              = "01-proelbtn-router"
 source_archive_id = "${data.sakuracloud_archive.01-proelbtn-router-archive.id}"
}

resource sakuracloud_disk "01-proelbtn-server-disk" {
 name              = "01-proelbtn-server"
 source_archive_id = "${data.sakuracloud_archive.01-proelbtn-server-archive.id}"
}

resource sakuracloud_server "router" {
 name            = "router"
 core            = 1
 memory          = 1
 disks           = ["${sakuracloud_disk.01-proelbtn-router-disk.id}"]
 nic             = "${sakuracloud_switch.vnc-switch.id}"
 additional_nics = ["${sakuracloud_switch.01-proelbtn-local.id}", ""]
}

resource sakuracloud_server "server" {
 name            = "server"
 core            = 1
 memory          = 1
 disks           = ["${sakuracloud_disk.01-proelbtn-server-disk.id}"]
 nic             = "${sakuracloud_switch.vnc-switch.id}"
 additional_nics = ["${sakuracloud_switch.01-proelbtn-local.id}"]
}