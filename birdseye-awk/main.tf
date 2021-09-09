terraform {
    required_providers {
      google = {
          source = "hashicorp/google"
          version = "3.5.0"
      }
    }
}

variable "credentials_path" {
    type = string
}

variable "project_name" {
    type = string
}

variable "region" {
    type = string
}

variable "dev_ip" {
    type = string
}

variable "db_user_password" {
    type = string
    sensitive = true
}

provider "google" {
    credentials = file(var.credentials_path)

    project = var.project_name
    region = var.region

}

resource "google_storage_bucket" "birdseye" {
    name = "birdseye_kay"
    location = var.region
    force_destroy = true
    project = var.project_name
}

resource "google_storage_bucket_object" "data_lake_folder" {
    name = "data_lake/"
    bucket = "${google_storage_bucket.birdseye.name}"
    content = "Empty directory"
}

resource "google_storage_bucket_object" "static_data_folder" {
    name = "static_data/"
    bucket = "${google_storage_bucket.birdseye.name}"
    content = "Empty directory"
}

resource "google_storage_bucket_object" "contract_type_csv" {
    name = "static_data/contract_type.csv"
    bucket = "${google_storage_bucket.birdseye.name}"
    source = "./data/contract_type.csv"
}

resource "google_storage_bucket_object" "salary_type_csv" {
    name = "static_data/salary_type.csv"
    bucket = "${google_storage_bucket.birdseye.name}"
    source = "./data/salary_type.csv"
}

resource "google_sql_database_instance" "birdseye-dwh" {
    database_version = "POSTGRES_13"
    name = "birdseye-dwh"

    settings {
        tier = "db-f1-micro"
        activation_policy = "ALWAYS"
        availability_type = "ZONAL"
        disk_autoresize = false
        disk_type = "PD_HDD"
        backup_configuration {
            enabled = false 
        }
        ip_configuration {
            ipv4_enabled = true 
            authorized_networks {
                value = var.dev_ip
            }
        }
    }


}

resource "google_sql_database" "dwh" {
    name = "dwh"
    instance = google_sql_database_instance.birdseye-dwh.name
    depends_on = [
      google_sql_database_instance.birdseye-dwh
    ]
}

resource "google_sql_user" "root_user" {
    instance = google_sql_database_instance.birdseye-dwh.name
    name = "root"
    password = var.db_user_password
    depends_on = [
      google_sql_database_instance.birdseye-dwh
    ]
}
