resource "yandex_vpc_security_group" "private-internal" {
 
 name        = "private-internal"
  description = "private internal subnet for websrv"
  network_id  = "${yandex_vpc_network.network-1.id}"
/*
 # ingress {
  #  description    = "Allow HTTP protocol from internal subnets"
 #   protocol       = "TCP"
 #   port           = "80"
 #   v4_cidr_blocks = ["0.0.0.0/0"]
 # }
#
#  ingress {
#    description    = "Allow HTTPS protocol from internal subnets"
#    protocol       = "TCP"
#    port           = "443"
#    v4_cidr_blocks = ["0.0.0.0/0"]
#  }
#
#  ingress {
#    description = "Health checks from NLB"
#    protocol = "TCP"
#    predefined_target = "loadbalancer_healthchecks" # [0.0.0.0/0]
#  }
#  
#  
#  ingress {
#    description    = "Allow ping"
#    protocol       = "ICMP"
#    v4_cidr_blocks = ["0.0.0.0/0"]
#  }

*/
  ingress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "pablic-zabbix" {
 
  name        = "Pablic-zabbix-rules"
  network_id  = "${yandex_vpc_network.network-1.id}"

  ingress {
    protocol       = "TCP"
    port           = "10050"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    port           = "10051"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    protocol       = "TCP"
    port           = "80"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

    
  ingress {
    description    = "Allow ping"
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "pablic-kibana" {
 
  name        = "Pablic-kibana-rules"
  network_id  = "${yandex_vpc_network.network-1.id}"

  ingress {
    protocol       = "TCP"
    port           = "5601"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

     
  ingress {
    description    = "Allow ping"
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "pablic-web-balancer" {
 
  name        = "Pablic-web-balancer-rules"
  network_id  = "${yandex_vpc_network.network-1.id}"

 
  ingress {
    protocol       = "TCP"
    port           = "80"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    protocol          = "ANY"
    description       = "Health checks"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    predefined_target = "loadbalancer_healthchecks"
  }
    
 
  ingress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
    protocol       = "ANY"
    description    = "allow any outgoing connection"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "bastion-external" {
 
  name        = "Bastion-rules-external"
  network_id  = "${yandex_vpc_network.network-1.id}"

  ingress {
    protocol       = "TCP"
    port           = "22"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

     
  ingress {
    description    = "Allow ping"
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
  resource "yandex_vpc_security_group" "bastion-internal" {
 
  name        = "Bastion-rules"
  network_id  = "${yandex_vpc_network.network-1.id}"

  ingress {
    protocol       = "TCP"
    port           = "22"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

     
  ingress {
    description    = "Allow ping"
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    description    = "Permit ANY"
    protocol       = "TCP"
    port           = "22"
    security_group_id = yandex_vpc_security_group.private-internal.id
  }
}