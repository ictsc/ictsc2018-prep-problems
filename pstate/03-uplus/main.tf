# 問題番号
variable "problem" {
  default = "03"
}

# vnc admin password
variable "VNC_SERVER_PASSWORD" {
  # default = ""
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

### 問題環境

## Switches

# IPv6 Segment 1
resource sakuracloud_switch "03-ipv6-01" {
    name = "03-ipv6-01"
}

# IPv6 Segment 2
resource sakuracloud_switch "03-ipv6-02" {
    name = "03-ipv6-02"
}


## Archives

data sakuracloud_archive "03-router-01-archive" {
  name_selectors = ["2018-prep1-03-router-01"]
}

data sakuracloud_archive "03-router-02-archive" {
  name_selectors = ["2018-prep1-03-router-02"]
}

data sakuracloud_archive "03-client-01-archive" {
  name_selectors = ["2018-prep1-03-client-01"]
}

data sakuracloud_archive "03-client-02-archive" {
  name_selectors = ["2018-prep1-03-client-02"]
}


## Disks

resource sakuracloud_disk "03-router-01-disk" {
  name              = "03-router-01"
  source_archive_id = "${data.sakuracloud_archive.03-router-01-archive.id}"
}

resource sakuracloud_disk "03-router-02-disk" {
  name              = "03-router-02"
  source_archive_id = "${data.sakuracloud_archive.03-router-02-archive.id}"
}

resource sakuracloud_disk "03-client-01-disk" {
  name              = "03-client-01"
  source_archive_id = "${data.sakuracloud_archive.03-client-01-archive.id}"
}

resource sakuracloud_disk "03-client-02-disk" {
  name              = "03-client-02"
  source_archive_id = "${data.sakuracloud_archive.03-client-02-archive.id}"
}


## Servers

# router 01
resource sakuracloud_server "03-router-01-server" {
  name            = "03-router-01"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.03-router-01-disk.id}"]
  nic             = "${sakuracloud_switch.03-ipv6-01.id}"
  # 192.168.0.1
  additional_nics = ["${sakuracloud_switch.vnc-switch.id}", "${sakuracloud_switch.03-ipv6-02.id}"]
}

# router 02
resource sakuracloud_server "03-router-02-server" {
  name            = "03-router-02"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.03-router-02-disk.id}"]
  nic             = "${sakuracloud_switch.03-ipv6-01.id}"
  # 検証用 v4でVNCからアクセスできる
  # 192.168.0.4
  # additional_nics = ["${sakuracloud_switch.vnc-switch.id}"]
}

# client 01
resource sakuracloud_server "03-client-01-server" {
  name            = "03-client-01"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.03-client-01-disk.id}"]
  nic             = "${sakuracloud_switch.03-ipv6-01.id}"
  # 192.168.0.2
  additional_nics = ["${sakuracloud_switch.vnc-switch.id}"]
}

# client 02
resource sakuracloud_server "03-client-02-server" {
  name            = "03-client-02"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.03-client-02-disk.id}"]
  nic             = "${sakuracloud_switch.03-ipv6-02.id}"
  # 検証用 v4でVNCからアクセスできる
  # 192.168.0.3
  # additional_nics = ["${sakuracloud_switch.vnc-switch.id}"]
}