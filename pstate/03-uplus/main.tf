# 問題番号
variable "PROBLEM" {
  default = "03-uplus"
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

# output
output "vnc_global_ip" {
  value = "${sakuracloud_server.vnc-server.ipaddress}"
}

### 問題環境

## Switches

# IPv6 Segment 1
resource sakuracloud_switch "03-ipv6-01" {
  name = "${var.PROBLEM}-ipv6-01-${var.TEAM_LOGIN_ID}"
  tags = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

# IPv6 Segment 2
resource sakuracloud_switch "03-ipv6-02" {
  name = "${var.PROBLEM}-ipv6-02-${var.TEAM_LOGIN_ID}"
  tags = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
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
  name              = "${var.PROBLEM}-router-01-${var.TEAM_LOGIN_ID}"
  source_archive_id = "${data.sakuracloud_archive.03-router-01-archive.id}"
  tags              = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

resource sakuracloud_disk "03-router-02-disk" {
  name              = "${var.PROBLEM}-router-02-${var.TEAM_LOGIN_ID}"
  source_archive_id = "${data.sakuracloud_archive.03-router-02-archive.id}"
  tags              = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

resource sakuracloud_disk "03-client-01-disk" {
  name              = "${var.PROBLEM}-client-01-${var.TEAM_LOGIN_ID}"
  source_archive_id = "${data.sakuracloud_archive.03-client-01-archive.id}"
  tags              = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

resource sakuracloud_disk "03-client-02-disk" {
  name              = "${var.PROBLEM}-client-02-${var.TEAM_LOGIN_ID}"
  source_archive_id = "${data.sakuracloud_archive.03-client-02-archive.id}"
  tags              = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

## Servers

# router 01
resource sakuracloud_server "03-router-01-server" {
  name   = "${var.PROBLEM}-router-01-${var.TEAM_LOGIN_ID}"
  core   = 1
  memory = 1
  disks  = ["${sakuracloud_disk.03-router-01-disk.id}"]
  nic    = "${sakuracloud_switch.03-ipv6-01.id}"

  # 192.168.0.1
  additional_nics = ["${sakuracloud_switch.vnc-switch.id}", "${sakuracloud_switch.03-ipv6-02.id}"]
  tags            = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

# router 02
resource sakuracloud_server "03-router-02-server" {
  name   = "${var.PROBLEM}-router-02-${var.TEAM_LOGIN_ID}"
  core   = 1
  memory = 1
  disks  = ["${sakuracloud_disk.03-router-02-disk.id}"]
  nic    = "${sakuracloud_switch.03-ipv6-01.id}"

  # 検証用 v4でVNCからアクセスできる
  # 192.168.0.4
  # additional_nics = ["${sakuracloud_switch.vnc-switch.id}"]
  tags = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

# client 01
resource sakuracloud_server "03-client-01-server" {
  name   = "${var.PROBLEM}-client-01-${var.TEAM_LOGIN_ID}"
  core   = 1
  memory = 1
  disks  = ["${sakuracloud_disk.03-client-01-disk.id}"]
  nic    = "${sakuracloud_switch.03-ipv6-01.id}"

  # 192.168.0.2
  additional_nics = ["${sakuracloud_switch.vnc-switch.id}"]
  tags            = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

# client 02
resource sakuracloud_server "03-client-02-server" {
  name   = "${var.PROBLEM}-client-02-${var.TEAM_LOGIN_ID}"
  core   = 1
  memory = 1
  disks  = ["${sakuracloud_disk.03-client-02-disk.id}"]
  nic    = "${sakuracloud_switch.03-ipv6-02.id}"

  # 検証用 v4でVNCからアクセスできる
  # 192.168.0.3
  # additional_nics = ["${sakuracloud_switch.vnc-switch.id}"]
  tags = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}
