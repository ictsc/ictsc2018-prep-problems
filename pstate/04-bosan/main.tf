
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
   name = "${var.PROBLEM}-vnc-init-${var.TEAM_LOGIN_ID}"
   class = "shell"
   content = "${file("start.sh")}"
   description = "VNCサーバ(踏み台)初期化スクリプト"
   tags = ["problem-${var.PROBLEM}","${var.TEAM_LOGIN_ID}","pstate_terraform"]
 }

 # vnc archive
 data sakuracloud_archive "vnc-archive" {
    name_selectors = ["VNC", "IMG" , "V3"]
 }

 # switch
 resource sakuracloud_switch "vnc-switch" {
    name = "${var.PROBLEM}-vnc-switch-${var.TEAM_LOGIN_ID}"
   tags = ["problem-${var.PROBLEM}","${var.TEAM_LOGIN_ID}","pstate_terraform"]
 }

 # disks
 resource sakuracloud_disk "vnc-server-disk" {
    name              = "-${var.PROBLEM}-vnc-server-disk-${var.TEAM_LOGIN_ID}"
    source_archive_id = "${data.sakuracloud_archive.vnc-archive.id}"
    note_ids          = ["${sakuracloud_note.vnc-init.id}"]
    tags = ["problem-${var.PROBLEM}","${var.TEAM_LOGIN_ID}","pstate_terraform"]
 }

 # servers
 resource sakuracloud_server "vnc-server" {
    name            = "${var.PROBLEM}-vnc-server(踏み台)-${var.TEAM_LOGIN_ID}"
    core            = 2
    memory          = 2
    disks           = ["${sakuracloud_disk.vnc-server-disk.id}"]
    nic             = "shared"
    additional_nics = ["${sakuracloud_switch.vnc-switch.id}"]
    tags = ["problem-${var.PROBLEM}","${var.TEAM_LOGIN_ID}","pstate_terraform"]
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

 ### ここから自由

 # switch

 resource sakuracloud_switch "04-bo_san-switch" {
     name = "${var.PROBLEM}-switch-${var.TEAM_LOGIN_ID}"
    tags = ["problem-${var.PROBLEM}","${var.TEAM_LOGIN_ID}","pstate_terraform"]
  }

 # Router1

 data sakuracloud_archive "04-bo_san-csr_Router1-archive" {
     name_selectors = ["2018-prep1-04-bo_san-csr_Router1"]
  }

  resource sakuracloud_disk "04-bo_san-csr_Router1-disk" {
     name              = "${var.PROBLEM}-csr_Router1-${var.TEAM_LOGIN_ID}"
     source_archive_id = "${data.sakuracloud_archive.04-bo_san-csr_Router1-archive.id}"
    tags = ["problem-${var.PROBLEM}","${var.TEAM_LOGIN_ID}","pstate_terraform"]
  }

  resource sakuracloud_server "bo_san-csr_Router1" {
     name            = "${var.PROBLEM}-csr_Router1-${var.TEAM_LOGIN_ID}"
     core            = 1
     memory          = 4
     disks           = ["${sakuracloud_disk.04-bo_san-csr_Router1-disk.id}"]
     nic             = "${sakuracloud_switch.vnc-switch.id}"
     additional_nics = ["${sakuracloud_switch.04-bo_san-switch.id}"]
   tags = ["problem-${var.PROBLEM}","${var.TEAM_LOGIN_ID}","pstate_terraform"] 
  }

 # Router2

 data sakuracloud_archive "04-bo_san-vyos_Router2-archive" {
     name_selectors = ["2018-prep1-04-bo_san-vyos_Router2"]
  }

  resource sakuracloud_disk "04-bo_san-vyos_Router2-disk" {
     name              = "${var.PROBLEM}-vyos_Router2-${var.TEAM_LOGIN_ID}"
     source_archive_id = "${data.sakuracloud_archive.04-bo_san-vyos_Router2-archive.id}"
    tags = ["problem-${var.PROBLEM}","${var.TEAM_LOGIN_ID}","pstate_terraform"]
  }

  resource sakuracloud_server "bo_san-vyos_Router2" {
     name            = "${var.PROBLEM-}vyos_Router2-${var.TEAM_LOGIN_ID}"
     core            = 1
     memory          = 1
     disks           = ["${sakuracloud_disk.04-bo_san-vyos_Router2-disk.id}"]
     nic             = "${sakuracloud_switch.04-bo_san-switch.id}"
    tags = ["problem-${var.PROBLEM}","${var.TEAM_LOGIN_ID}","pstate_terraform"]
  }