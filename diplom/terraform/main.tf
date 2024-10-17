terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.129.0"
    }
  }
}


provider "yandex" {
  service_account_key_file = var.account_key_file
  cloud_id  = var.yc-token-cloud
  folder_id = var.yc-token-folder
  
}


#--------------------------- target group -----------------------------

resource "yandex_alb_target_group" "tg-group" {
  name = "tg-group"

  target {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    ip_address = "${yandex_compute_instance.web-srv-1.network_interface[0].ip_address}"
  }

  target {
    subnet_id = "${yandex_vpc_subnet.subnet-2.id}"
    ip_address = "${yandex_compute_instance.web-srv-2.network_interface[0].ip_address}"
  }
}


#--------------------------- backend group -----------------------------

resource "yandex_alb_backend_group" "bck-group" {
  name                     = "bck-group"
  
  http_backend {
    name                   = "http-bck"
    weight                 = 1
    port                   = 80
    target_group_ids       = ["${yandex_alb_target_group.tg-group.id}"]
    
    load_balancing_config {
      panic_threshold      = 90
    }
    
    healthcheck {
      timeout = "1s"
      interval = "1s"
      http_healthcheck {
        path  = "/"
      }
    }
  }
}


#--------------------------- http router -----------------------------

resource "yandex_alb_http_router" "tf-router" {
  name = "tf-router" 
}

resource "yandex_alb_virtual_host" "virtual-host" {
  name                    = "virtual-host"
  http_router_id          = yandex_alb_http_router.tf-router.id
  route {
    name                  = "my-rote"
    http_route {
      http_route_action {
        backend_group_id  = yandex_alb_backend_group.bck-group.id
        timeout           = "60s"
      }
      http_match {
        path {
          prefix = "/"
        }
      }
    }
  }
}


#--------------------------- balancer -----------------------------

resource "yandex_alb_load_balancer" "web-balancer" {
  name        = "web-balancer"
  network_id  = yandex_vpc_network.network-1.id
  security_group_ids = [
                        yandex_vpc_security_group.pablic-web-balancer.id, 
                        yandex_vpc_security_group.private-internal.id,
                        yandex_vpc_security_group.bastion-external.id,
                        yandex_vpc_security_group.bastion-internal.id
                       ]
  
  allocation_policy {
    location {
      zone_id   = var.zone_b
      subnet_id = yandex_vpc_subnet.public.id
    }
    
  }
  
  listener {
    name = "web-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }    
    http {
      handler {
        http_router_id = yandex_alb_http_router.tf-router.id
      }
    }
  }
}


#--------------------------- nginx_web_srv_1 -----------------------------

resource "yandex_compute_instance" "web-srv-1" {
  name = "web-srv-1"
  hostname = "web1"
  allow_stopping_for_update = true
  platform_id = var.platform_v3
  zone = var.zone_a

  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }

  
  boot_disk {
    disk_id = yandex_compute_disk.web-srv-disk1.id
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    ip_address = "10.128.1.10"
    nat = false
    security_group_ids = [
                          yandex_vpc_security_group.private-internal.id, 
                          yandex_vpc_security_group.bastion-internal.id, 
                          yandex_vpc_security_group.pablic-web-balancer.id
                          ]
    dns_record {
      fqdn = "web1.srv."
    }
  }

  metadata = {
    user-data = "${file("./meta.yaml")}"
  }

  scheduling_policy {
    preemptible = true
  }

}


#--------------------------- nginx_web_srv_2 -----------------------------

resource "yandex_compute_instance" "web-srv-2" {
  name = "web-srv-2"
  hostname = "web2"
  allow_stopping_for_update = true
  platform_id = var.platform_v3
  zone = var.zone_b

  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id = yandex_compute_disk.web-srv-disk2.id
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-2.id}"
    ip_address = "10.128.2.10"
    security_group_ids =[
                          yandex_vpc_security_group.private-internal.id,
                          yandex_vpc_security_group.bastion-internal.id,
                          yandex_vpc_security_group.pablic-web-balancer.id
                         ]
    dns_record {
      fqdn = "web2.srv."
    }
  }

  metadata = {
    user-data = "${file("./meta.yaml")}"
  }

  scheduling_policy {
    preemptible = true
  }

}


#--------------------------- Elasticsearch -----------------------------

resource "yandex_compute_instance" "elasticsearch" {
  name = "elasticsearch"
  hostname = "elastic"
  allow_stopping_for_update = true
  platform_id = var.platform_v3
  zone = var.zone_b

  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id = yandex_compute_disk.elasticsearch-disk.id
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.private.id}"
    ip_address = "10.128.3.10"
    security_group_ids = [
                          yandex_vpc_security_group.private-internal.id,
                          yandex_vpc_security_group.bastion-internal.id,
                          yandex_vpc_security_group.bastion-external.id
                         ]
    dns_record {
      fqdn = "elastic.srv."
    }
  }

  metadata = {
    user-data = "${file("./meta.yaml")}"
  }


  scheduling_policy {
    preemptible = true
  }

}


#--------------------------- Zabbix -----------------------------

resource "yandex_compute_instance" "zabbix" {
  name = "zabbix"
  hostname = "zabbix"
  allow_stopping_for_update = true
  platform_id = var.platform_v3
  zone = var.zone_b

  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id = yandex_compute_disk.zabbix-disk.id
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.public.id}"
    nat = true
    ip_address = "10.128.4.10"
    security_group_ids = [
                          yandex_vpc_security_group.pablic-zabbix.id, 
                          yandex_vpc_security_group.private-internal.id,
                          yandex_vpc_security_group.bastion-internal.id,
                          yandex_vpc_security_group.bastion-external.id
                          ]
    
    dns_record {
      fqdn = "zabix.srv."
    }
  }

  metadata = {
    user-data = "${file("./meta.yaml")}"
  }


  scheduling_policy {
    preemptible = true
  }

}


#--------------------------- Kibana -----------------------------

resource "yandex_compute_instance" "kibana" {
  name = "kibana"
  hostname = "kibana"
  allow_stopping_for_update = true
  platform_id = var.platform_v3
  zone = var.zone_b

  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id = yandex_compute_disk.kibanah-disk.id
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.public.id}"
    nat = true
    ip_address = "10.128.4.11"
    security_group_ids = [
                          yandex_vpc_security_group.pablic-kibana.id, 
                          yandex_vpc_security_group.private-internal.id,
                          yandex_vpc_security_group.bastion-external.id,
                          yandex_vpc_security_group.bastion-internal.id
                          ]

    dns_record {
      fqdn = "kibaana.srv."
    }
  }


  metadata = {
    user-data = "${file("./meta.yaml")}"
  }


  scheduling_policy {
    preemptible = true
  }

}


#--------------------------- Bastion -----------------------------

resource "yandex_compute_instance" "bastion" {
  name = "bastion"
  hostname = "bastion"
  allow_stopping_for_update = true
  platform_id = var.platform_v3
  zone = var.zone_b

  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id = yandex_compute_disk.bastion-disk.id
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.public.id}"
    nat = true
    ip_address = "10.128.4.15"
    security_group_ids = [
                          yandex_vpc_security_group.bastion-internal.id, 
                          yandex_vpc_security_group.bastion-external.id,
                          yandex_vpc_security_group.private-internal.id,
                          yandex_vpc_security_group.pablic-kibana.id,
                          yandex_vpc_security_group.pablic-zabbix.id
                        ]

    dns_record {
      fqdn = "bastion.srv."
    }
  }


  metadata = {
    user-data = "${file("./meta.yaml")}"
  }


  scheduling_policy {
    preemptible = true
  }

}