#--------------------------- disk_web_srv_1-----------------------------

resource "yandex_compute_disk" "web-srv-disk1" {
  name = "web-srv-disk1"
  type = "network-hdd"
  zone = var.zone_a
  size = 10
  image_id = "fd834mcknpoei6h5ve3a"
}


#--------------------------- disk_web_srv_2-----------------------------

resource "yandex_compute_disk" "web-srv-disk2" {
  name = "web-srv-disk2"
  type = "network-hdd"
  zone = var.zone_b
  size = 10
  image_id = "fd834mcknpoei6h5ve3a"
}


#--------------------------- zabbix-----------------------------

resource "yandex_compute_disk" "zabbix-disk" {
  name = "zabbix-disk"
  type = "network-hdd"
  zone = var.zone_b
  size = 10
  image_id = "fd834mcknpoei6h5ve3a"
}


#--------------------------- elasticsearch-----------------------------

resource "yandex_compute_disk" "elasticsearch-disk" {
  name = "elasticsearch-disk"
  type = "network-hdd"
  zone = var.zone_b
  size = 10
  image_id = "fd834mcknpoei6h5ve3a"
}


#--------------------------- kibana-----------------------------

resource "yandex_compute_disk" "kibanah-disk" {
  name = "kibana-disk"
  type = "network-hdd"
  zone = var.zone_b
  size = 10
  image_id = "fd834mcknpoei6h5ve3a"
}


#--------------------------- bastion-----------------------------

resource "yandex_compute_disk" "bastion-disk" {
  name = "bastion-disk"
  type = "network-hdd"
  zone = var.zone_b
  size = 10
  image_id = "fd834mcknpoei6h5ve3a"
}