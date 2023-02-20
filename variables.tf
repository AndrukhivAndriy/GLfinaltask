variable "region" {
  description = "System region"
  default     = "eu-central-1"
}

variable "instance_type_k8s" {
  description = "Instance type in K8s"
  default     = "n1-standard-4"
}

variable "instance_image_k8s" {
  description = "Instance image in K8s"
  default     = "ubuntu-os-cloud/ubuntu-2004-lts"
}

variable "DB_version" {
  description = "DB version"
  default     = "MYSQL_8_0"
}

variable "DB_instance_tier" {
  description = "Type of DB Instance"
  default     = "db-f1-micro"
}

variable "DBusername" {
  description = "Db username"
  type = string
}

variable "DBpassword" {
  description = "Db password"
  type = string
}

variable "DB_name" {
  description = "Db name"
  default     = "wordpress-db"
}

variable "secgr_ports" {
  description = "Open ports"
  type = list
  default     = ["80", "22", "443"]
}
