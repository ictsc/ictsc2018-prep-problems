# 問題番号
variable "PROBLEM" {
  default = "01-kanata"
}

# チーム番号
variable "TEAM_LOGIN_ID" {
  default = "PUT_TEAM_NUMBER_HERE"
}

variable "WEBHOOK_URL" {
  default = "https://hooks.slack.com/services/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"
}

# vnc admin password
variable "VNC_SERVER_PASSWORD" {
  default = "PUT_YOUR_PASSWORD_HERE"
}

# script
resource sakuracloud_note "vnc-init" {
  name        = "${var.PROBLEM}-vnc-init-${var.TEAM_LOGIN_ID}"
  class       = "shell"
  content     = "${file("start.sh")}"
  description = "VNCサーバ(踏み台)初期化スクリプト"
  tags        = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

# vnc archive
data sakuracloud_archive "vnc-archive" {
  name_selectors = ["VNC", "IMG", "V3"]
}

# switch
resource sakuracloud_switch "vnc-switch" {
  name = "${var.PROBLEM}-vnc-switch-${var.TEAM_LOGIN_ID}"
  tags = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

# disks
resource sakuracloud_disk "vnc-server-disk" {
  name              = "${var.PROBLEM}-vnc-server-disk-${var.TEAM_LOGIN_ID}"
  source_archive_id = "${data.sakuracloud_archive.vnc-archive.id}"
  note_ids          = ["${sakuracloud_note.vnc-init.id}"]
  tags              = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

# servers
resource sakuracloud_server "vnc-server" {
  name            = "${var.PROBLEM}-vnc-server(踏み台)-${var.TEAM_LOGIN_ID}"
  core            = 2
  memory          = 2
  disks           = ["${sakuracloud_disk.vnc-server-disk.id}"]
  nic             = "shared"
  additional_nics = ["${sakuracloud_switch.vnc-switch.id}"]
  tags            = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

# output
output "vnc_global_ip" {
  value = "${sakuracloud_server.vnc-server.ipaddress}"
}

# simple_monitor
resource sakuracloud_simple_monitor "vnc-monitor" {
  target = "${sakuracloud_server.vnc-server.ipaddress}"

  health_check = {
    protocol   = "ping"
    delay_loop = 60
  }

  notify_email_enabled = false
  notify_slack_enabled = true
  notify_slack_webhook = "${var.WEBHOOK_URL}"
  tags                 = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
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
  name              = "${var.PROBLEM}-01-${var.TEAM_LOGIN_ID}"
  hostname          = "kube01"
  password          = "kubernetes"
  source_archive_id = "${data.sakuracloud_archive.prep1-01-kanata_archive_1.id}"
  tags              = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

resource sakuracloud_disk "prep1-01-kanata_disk_02" {
  name              = "${var.PROBLEM}-02-${var.TEAM_LOGIN_ID}"
  hostname          = "kube02"
  password          = "kubernetes"
  source_archive_id = "${data.sakuracloud_archive.prep1-01-kanata_archive_2.id}"
  tags              = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

resource sakuracloud_disk "prep1-01-kanata_disk_03" {
  name              = "${var.PROBLEM}-03-${var.TEAM_LOGIN_ID}"
  hostname          = "kube03"
  password          = "kubernetes"
  source_archive_id = "${data.sakuracloud_archive.prep1-01-kanata_archive_3.id}"
  tags              = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

## servers

resource sakuracloud_server "prep1-01-kanata_1" {
  name        = "${var.PROBLEM}-01-${var.TEAM_LOGIN_ID}"
  core        = 1
  memory      = 1
  disks       = ["${sakuracloud_disk.prep1-01-kanata_disk_01.id}"]
  nic         = "${sakuracloud_switch.vnc-switch.id}"
  ipaddress   = "192.168.0.1"
  nw_mask_len = "24"
  gateway     = "192.168.0.254"
  tags        = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

resource sakuracloud_server "prep1-01-kanata_2" {
  name        = "${var.PROBLEM}-02-${var.TEAM_LOGIN_ID}"
  core        = 1
  memory      = 1
  disks       = ["${sakuracloud_disk.prep1-01-kanata_disk_02.id}"]
  nic         = "${sakuracloud_switch.vnc-switch.id}"
  ipaddress   = "192.168.0.2"
  nw_mask_len = "24"
  gateway     = "192.168.0.254"
  tags        = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

resource sakuracloud_server "prep1-01-kanata_3" {
  name        = "${var.PROBLEM}-03-${var.TEAM_LOGIN_ID}"
  core        = 1
  memory      = 1
  disks       = ["${sakuracloud_disk.prep1-01-kanata_disk_03.id}"]
  nic         = "${sakuracloud_switch.vnc-switch.id}"
  ipaddress   = "192.168.0.3"
  nw_mask_len = "24"
  gateway     = "192.168.0.254"
  tags        = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}
