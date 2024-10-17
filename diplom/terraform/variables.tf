variable "zone_a" {
  type = string
  default = "ru-central1-a"
}

variable "zone_b" {
 type = string
 default = "ru-central1-b"
 }

 variable "zone_d" {
    type = string
    default = "ru-central1-d"
 }

 variable "account_key_file" {
    type = string
    default = "/home/eugene/diplom/terraform/authorized_key.json"
    sensitive = true
 }

 variable "platform_v3" {
    type = string
    default = "standard-v3"
   
 }