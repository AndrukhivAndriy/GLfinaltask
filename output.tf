output "database_ip" {
  value = google_sql_database_instance.main_primary.ip_address
}

output "database_name" {
  value = google_sql_database.db_wordpress.name
}


