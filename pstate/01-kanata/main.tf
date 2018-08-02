variable "VNC_SERVER_PASSWORD"{
}

data sakuracloud_archive "vnc-archive" {
    name_selectors = ["VNC", "IMG", "V2"]
}
data sakuracloud_archive "prep1-01-kanata_archive_1" {
  name_selectors = ["2018-prep1-01-kanata_01"]
}
data sakuracloud_archive "prep1-01-kanata_archive_2" {
  name_selectors = ["2018-prep1-01-kanata_02"]
}
data sakuracloud_archive "prep1-01-kanata_archive_3" {
  name_selectors = ["2018-prep1-01-kanata_03"]
}

# スタートアップスクリプト
resource sakuracloud_note "vnc-init" {
  name = "vnc-init"
  class = "shell"
  content = "${file("start.sh")}"
  description = "VNCサーバ(踏み台)初期化スクリプト"
}

# スイッチ
resource sakuracloud_switch "prep1-01-kanata_switch" {
  name  = "prep1-01-kanata"
}

# ディスク
resource sakuracloud_disk "prep1-01-kanata_vnc-server_disk" {
# name              = "prep1-01-kanata_vnc-server"
  name              = "vnc-server-disk"
  source_archive_id = "${data.sakuracloud_archive.vnc-archive.id}"
  note_ids = ["${sakuracloud_note.vnc-init.id}"]
  password = "testtesttest"
}
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

# サーバー
resource sakuracloud_server "prep1-01-kanata_vnc-server" {
# name            = "prep1-01-kanata_vnc-server"
  name            = "vnc-server(踏み台)"
  core            = 2
  memory          = 2
  disks           = ["${sakuracloud_disk.prep1-01-kanata_vnc-server_disk.id}"]
  nic             = "shared"
  additional_nics = ["${sakuracloud_switch.prep1-01-kanata_switch.id}"]
}
resource sakuracloud_server "prep1-01-kanata_1" {
  name            = "prep1-01-kanata_01"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.prep1-01-kanata_disk_01.id}"]
  nic             = "${sakuracloud_switch.prep1-01-kanata_switch.id}"
  ipaddress       = "192.168.0.1"
  nw_mask_len     = "24"
  gateway         = "192.168.0.254"
}
resource sakuracloud_server "prep1-01-kanata_2" {
  name            = "prep1-01-kanata_02"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.prep1-01-kanata_disk_02.id}"]
  nic             = "${sakuracloud_switch.prep1-01-kanata_switch.id}"
  ipaddress       = "192.168.0.2"
  nw_mask_len     = "24"
  gateway         = "192.168.0.254"
}
resource sakuracloud_server "prep1-01-kanata_3" {
  name            = "prep1-01-kanata_03"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.prep1-01-kanata_disk_03.id}"]
  nic             = "${sakuracloud_switch.prep1-01-kanata_switch.id}"
  ipaddress       = "192.168.0.3"
  nw_mask_len     = "24"
  gateway         = "192.168.0.254"
}

output "vnc_global_ip" {
    value = "${sakuracloud_server.prep1-01-kanata_vnc-server.ipaddress}"
}