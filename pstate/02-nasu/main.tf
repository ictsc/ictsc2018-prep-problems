# 問題番号
variable "PROBLEM" {
  default = "02-nasu"
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

  notify_slack_enabled = true
  notify_slack_webhook = "${var.WEBHOOK_URL}"
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
  name    = "${var.PROBLEM}-snmp-script-${var.TEAM_LOGIN_ID}"
  class   = "shell"
  content = "${file("vyos.sh")}"
  tags    = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

## disks

resource sakuracloud_disk "02-zabbix-disk" {
  name              = "${var.PROBLEM}-zabbix-${var.TEAM_LOGIN_ID}"
  source_archive_id = "${data.sakuracloud_archive.02-zabbix-archive.id}"
  tags              = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

resource sakuracloud_disk "02-grafana-disk" {
  name              = "${var.PROBLEM}-grafana-${var.TEAM_LOGIN_ID}"
  source_archive_id = "${data.sakuracloud_archive.02-grafana-archive.id}"
  tags              = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

resource sakuracloud_disk "02-snmp-disk" {
  name              = "${var.PROBLEM}-snmp-${var.TEAM_LOGIN_ID}"
  source_archive_id = "${data.sakuracloud_archive.02-snmp-archive.id}"
  note_ids          = ["${sakuracloud_note.02-snmp-script.id}"]
  tags              = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

## servers
resource sakuracloud_server "02-zabbix-server" {
  name   = "${var.PROBLEM}-zabbix-server-${var.TEAM_LOGIN_ID}"
  core   = 1
  memory = 1
  disks  = ["${sakuracloud_disk.02-zabbix-disk.id}"]
  nic    = "${sakuracloud_switch.vnc-switch.id}"
  tags   = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

resource sakuracloud_server "02-grafana-server" {
  name   = "${var.PROBLEM}-grafana-${var.TEAM_LOGIN_ID}"
  core   = 1
  memory = 1
  disks  = ["${sakuracloud_disk.02-grafana-disk.id}"]
  nic    = "${sakuracloud_switch.vnc-switch.id}"
  tags   = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}

resource sakuracloud_server "02-snmp-server" {
  name   = "${var.PROBLEM}-snmp-server-${var.TEAM_LOGIN_ID}"
  core   = 1
  memory = 1
  disks  = ["${sakuracloud_disk.02-snmp-disk.id}"]
  nic    = "${sakuracloud_switch.vnc-switch.id}"
  tags   = ["problem-${var.PROBLEM}", "${var.TEAM_LOGIN_ID}", "pstate_terraform"]
}
