# 問題番号
variable "problem" {
    default = "06"
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

data sakuracloud_archive "06-lb-archive" {
    name_selectors = ["2018-prep1-06-lb"]
}

data sakuracloud_archive "06-http-server-A-archive" {
    name_selectors = ["2018-prep1-06-http-server-A"]
}

data sakuracloud_archive "06-http-server-B-archive" {
    name_selectors = ["2018-prep1-06-http-server-B"]
}

resource sakuracloud_disk "06-lb-disk" {
    name              = "06-lb"
    source_archive_id = "${data.sakuracloud_archive.06-lb-archive.id}"
}

resource sakuracloud_disk "06-http-server-A-disk" {
    name              = "06-http-server-A"
    source_archive_id = "${data.sakuracloud_archive.06-http-server-A-archive.id}"
}

resource sakuracloud_disk "06-http-server-B-disk" {
    name              = "06-http-server-B"
    source_archive_id = "${data.sakuracloud_archive.06-http-server-B-archive.id}"
}

resource sakuracloud_server "06-lb-server" {
    name            = "06-lb"
    core            = 1
    memory          = 1
    disks           = ["${sakuracloud_disk.06-lb-disk.id}"]
    nic             = "${sakuracloud_switch.vnc-switch.id}"
}

resource sakuracloud_server "06-http-server-A-server" {
    name            = "06-http-server-A"
    core            = 1
    memory          = 1
    disks           = ["${sakuracloud_disk.06-http-server-A-disk.id}"]
    nic             = "${sakuracloud_switch.vnc-switch.id}"
}

resource sakuracloud_server "06-http-server-B-server" {
    name            = "06-http-server-B"
    core            = 1
    memory          = 1
    disks           = ["${sakuracloud_disk.06-http-server-B-disk.id}"]
    nic             = "${sakuracloud_switch.vnc-switch.id}"
}