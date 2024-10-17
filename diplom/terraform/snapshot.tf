resource "yandex_compute_snapshot_schedule" "snapshot" {
  name           = "snapshot"

  schedule_policy {
	expression = "0 3 ? * *"
  }

  snapshot_count = 1

  retention_period = "168h"

  snapshot_spec {
	  description = "snapshot-description"
	  
  }

    disk_ids = [ 
                "${yandex_compute_disk.web-srv-disk1.id}",
                "${yandex_compute_disk.web-srv-disk2.id}",
                "${yandex_compute_disk.elasticsearch-disk.id}",
                "${yandex_compute_disk.bastion-disk.id}",
                "${yandex_compute_disk.kibanah-disk.id}",
                "${yandex_compute_disk.zabbix-disk.id}"
                ]

}

