# Configure the provider for Google Cloud
provider "google" {
  credentials = file("mygcp-creds.json")
  project = "direct-builder-276316"
  region  = "europe-west1"
  zone = "europe-west1-b"
}

# Create a VPC network with a subnet
resource "google_compute_network" "vpc_network" {
  name                    = "vpcwordpress"
 # auto_create_subnetworks = true
}

resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "wordpress-subnet"
  ip_cidr_range = "10.0.10.0/24"
  network       = google_compute_network.vpc_network.self_link
}

# Create a firewall rule to allow incoming traffic
resource "google_compute_firewall" "allow_http" {
  name    = "httpssh"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = var.secgr_ports
  }

  source_ranges = ["0.0.0.0/0"]
}

# Create the compute instance
resource "google_compute_instance" "wordpress_instance" {
  name         = "wordpress-instance"
  machine_type = var.instance_type_k8s

  boot_disk {
    initialize_params {
      image = var.instance_image_k8s
      size  = 50
    }
  }
metadata = {
    ssh-keys = "ubuntu:${file("id_rsa.pub")}"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.vpc_subnet.self_link
    network = google_compute_network.vpc_network.self_link

    access_config {
      // Use ephemeral IP address
    }
  }

  metadata_startup_script = file("startup.sh")

  tags = ["httpssh"]
}

resource "google_compute_global_address" "private_ip_block" {
  name         = "private-ip-block"
  purpose      = "VPC_PEERING"
  address_type = "INTERNAL"
  ip_version   = "IPV4"
  prefix_length = 20
  network       = google_compute_network.vpc_network.name
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_block.name]
}

resource "google_sql_database_instance" "main_primary" {
  name             = "main-primary"
  database_version = var.DB_version
  depends_on       = [google_service_networking_connection.private_vpc_connection]
  settings {
    tier              = var.DB_instance_tier
   
    disk_size         = 10  # 10 GB is the smallest disk size    
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc_network.self_link
    }
  }
}

# Set up a database user for accessing the instance
resource "google_sql_user" "wordpress_user" {
  name        = var.DBusername
  instance    = google_sql_database_instance.main_primary.name
  password    = var.DBpassword
  depends_on  = [google_sql_database_instance.main_primary]
}

# Set up a database for the instance
resource "google_sql_database" "db_wordpress" {
  name     = var.DB_name
  charset = "UTF8"
  collation = "utf8_general_ci"
  instance = google_sql_database_instance.main_primary.name
  depends_on = [google_sql_database_instance.main_primary]
}