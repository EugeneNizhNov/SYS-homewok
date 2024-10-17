#--------------------------- net -----------------------------

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}


resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "route-table" {
  name       = "route_table"
  network_id = yandex_vpc_network.network-1.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}


#--------------------------- subnet_1 -----------------------------

resource "yandex_vpc_subnet" "subnet-1" {
  name = "subnet1"
  zone = var.zone_a
  v4_cidr_blocks = ["10.128.1.0/24"]
  network_id = "${yandex_vpc_network.network-1.id}"
  route_table_id = yandex_vpc_route_table.route-table.id
}


#--------------------------- subnet_2 -----------------------------

resource "yandex_vpc_subnet" "subnet-2" {
  name = "subnet2"
  zone = var.zone_b
  v4_cidr_blocks = ["10.128.2.0/24"]
  network_id = "${yandex_vpc_network.network-1.id}"
  route_table_id =  yandex_vpc_route_table.route-table.id
}


#--------------------------- private -----------------------------

resource "yandex_vpc_subnet" "private" {
  name = "private"
  zone = var.zone_b
  v4_cidr_blocks = ["10.128.3.0/24"]
  network_id = "${yandex_vpc_network.network-1.id}"
  route_table_id =  yandex_vpc_route_table.route-table.id
}


#--------------------------- public -----------------------------

resource "yandex_vpc_subnet" "public" {
  name = "public"
  zone = var.zone_b
  v4_cidr_blocks = ["10.128.4.0/24"]
  network_id = "${yandex_vpc_network.network-1.id}"
}
