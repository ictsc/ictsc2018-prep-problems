# 問題番号
variable "PROBLEM" {
  default = "04-toyoda"
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

### ここから自由

# switch

resource sakuracloud_switch "04-toyoda-switch" {
  name = "${var.PROBLEM}-switch-${var.TEAM_LOGIN_ID}"
  tags = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

# Router-A

data sakuracloud_archive "04-toyoda-Router-A-archive" {
  name_selectors = ["2018-prep1-04-toyoda-Router-A"]
}

resource sakuracloud_disk "04-toyoda-Router-A-disk" {
  name              = "${var.PROBLEM}-Router-A-${var.TEAM_LOGIN_ID}"
  source_archive_id = "${data.sakuracloud_archive.04-toyoda-Router-A-archive.id}"
  tags              = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

resource sakuracloud_server "toyoda-Router-A" {
  name            = "${var.PROBLEM}-toyoda-Router-A-${var.TEAM_LOGIN_ID}"
  core            = 1
  memory          = 4
  disks           = ["${sakuracloud_disk.04-toyoda-Router-A-disk.id}"]
  nic             = "${sakuracloud_switch.vnc-switch.id}"
  additional_nics = ["${sakuracloud_switch.04-toyoda-switch.id}"]
  tags            = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

# Router-B

data sakuracloud_archive "04-toyoda-Router-B-archive" {
  name_selectors = ["2018-prep1-04-toyoda-Router-B"]
}

resource sakuracloud_disk "04-toyoda-Router-B-disk" {
  name              = "${var.PROBLEM}-Router-B-${var.TEAM_LOGIN_ID}"
  source_archive_id = "${data.sakuracloud_archive.04-toyoda-Router-B-archive.id}"
  tags              = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

resource sakuracloud_server "toyoda-Router-B" {
  name            = "${var.PROBLEM}-Router-B-${var.TEAM_LOGIN_ID}"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.04-toyoda-Router-B-disk.id}"]
  nic             = "${sakuracloud_switch.04-toyoda-switch.id}"
  additional_nics = ["${sakuracloud_switch.vnc-switch.id}"]
  tags            = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}
