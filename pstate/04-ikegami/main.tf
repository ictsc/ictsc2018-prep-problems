# 問題番号
variable "PROBLEM" {
  default = "04-ikegami"
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

# ikegami add
resource sakuracloud_note "vnc-ikegami" {
  name    = "${var.PROBLEM}-vnc-ikegami-${var.TEAM_LOGIN_ID}"
  class   = "shell"
  content = "${file("vnc-ikegami.sh")}"
  tags    = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
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
  name              = "-${var.PROBLEM}-vnc-server-disk-${var.TEAM_LOGIN_ID}"
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

  notify_slack_enabled = true
  notify_slack_webhook = "${var.WEBHOOK_URL}"
}

### 以下自由に書く

## Switches

# gw-osaka
resource sakuracloud_switch "04-ikegami-gw-osaka" {
  name = "${var.PROBLEM}-gw-osaka-${var.TEAM_LOGIN_ID}"
  tags = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

# gw-tokyo
resource sakuracloud_switch "04-ikegami-gw-tokyo" {
  name = "${var.PROBLEM}-gw-tokyo-${var.TEAM_LOGIN_ID}"
  tags = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

# osaka-fumidai
resource sakuracloud_switch "04-ikegami-osaka-fumidai" {
  name = "${var.PROBLEM}-osaka-fumidai-${var.TEAM_LOGIN_ID}"
  tags = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

# tokyo-ping
resource sakuracloud_switch "04-ikegami-tokyo-ping" {
  name = "${var.PROBLEM}-tokyo-ping-${var.TEAM_LOGIN_ID}"
  tags = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
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
  name              = "${var.PROBLEM}-fumidai-${var.TEAM_LOGIN_ID}"
  source_archive_id = "${data.sakuracloud_archive.04-ikegami-fumidai-archive.id}"
  tags              = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

resource sakuracloud_disk "04-ikegami-tokyo-disk" {
  name              = "${var.PROBLEM}-ikegami-tokyo-${var.TEAM_LOGIN_ID}"
  source_archive_id = "${data.sakuracloud_archive.04-ikegami-tokyo-archive.id}"
  tags              = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

resource sakuracloud_disk "04-ikegami-osaka-disk" {
  name              = "${var.PROBLEM}-osaka-${var.TEAM_LOGIN_ID}"
  source_archive_id = "${data.sakuracloud_archive.04-ikegami-osaka-archive.id}"
  tags              = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

resource sakuracloud_disk "04-ikegami-ping-disk" {
  name              = "${var.PROBLEM}-ping-${var.TEAM_LOGIN_ID}"
  source_archive_id = "${data.sakuracloud_archive.04-ikegami-ping-archive.id}"
  tags              = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

resource sakuracloud_disk "04-ikegami-router1-disk" {
  name              = "${var.PROBLEM}-router1-${var.TEAM_LOGIN_ID}"
  source_archive_id = "${data.sakuracloud_archive.04-ikegami-router1-archive.id}"
  tags              = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

## Servers

# router1
resource sakuracloud_server "04-ikegami-router1-server" {
  name            = "${var.PROBLEM}-router1-${var.TEAM_LOGIN_ID}"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.04-ikegami-router1-disk.id}"]
  nic             = "${sakuracloud_switch.vnc-switch.id}"
  additional_nics = ["${sakuracloud_switch.04-ikegami-gw-tokyo.id}", "${sakuracloud_switch.04-ikegami-gw-osaka.id}"]
  tags            = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

# osaka
resource sakuracloud_server "04-ikegami-osaka-server" {
  name            = "${var.TEAM_LOGIN_ID}-osaka-${var.TEAM_LOGIN_ID}"
  core            = 1
  memory          = 4
  disks           = ["${sakuracloud_disk.04-ikegami-osaka-disk.id}"]
  nic             = "${sakuracloud_switch.04-ikegami-gw-osaka.id}"
  additional_nics = ["${sakuracloud_switch.04-ikegami-osaka-fumidai.id}"]
  tags            = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

# tokyo
resource sakuracloud_server "04-ikegami-tokyo-server" {
  name            = "${var.PROBLEM}-tokyo-${var.TEAM_LOGIN_ID}"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.04-ikegami-tokyo-disk.id}"]
  nic             = "${sakuracloud_switch.04-ikegami-gw-tokyo.id}"
  additional_nics = ["${sakuracloud_switch.04-ikegami-tokyo-ping.id}"]
  tags            = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

# ping
resource sakuracloud_server "04-ikegami-ping-server" {
  name   = "${var.PROBLEM}-ping-${var.TEAM_LOGIN_ID}"
  core   = 1
  memory = 1
  disks  = ["${sakuracloud_disk.04-ikegami-ping-disk.id}"]
  nic    = "${sakuracloud_switch.04-ikegami-tokyo-ping.id}"
  tags   = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

# fumidai
resource sakuracloud_server "04-ikegami-fumidai-server" {
  name            = "${var.PROBLEM}-fumidai-${var.TEAM_LOGIN_ID}"
  core            = 1
  memory          = 1
  disks           = ["${sakuracloud_disk.04-ikegami-fumidai-disk.id}"]
  nic             = "${sakuracloud_switch.04-ikegami-osaka-fumidai.id}"
  additional_nics = ["${sakuracloud_switch.vnc-switch.id}"]
}
