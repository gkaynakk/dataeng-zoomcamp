variable "region" {
  description = "GCP Region"
  default     = "us-central1"
  
}

variable "project" {
    description = "Project"
    default = "project-9dccbae3-37b5-4c84-9b7"
  
}


variable "location" {
  description = "GCP Location"
  default     = "US"


}

variable "gcs_storage_class" {
  description = "GCS Storage Class"
  default     = "STANDARD"
  type        = string
}

variable "bq_dataset_name" {
  description = "My BigQuery dataset name"
  default     = "demo_dataset"
}

variable "gcs_bucket_name" {
  description = "GCS Bucket Name"
  default     = "project-9dccbae3-37b5-4c84-9b7"

}