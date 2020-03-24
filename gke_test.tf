variable "location" {
  type    = string
  default = "us-central1"
}

variable "GCP_JSON_KEY" {
  type    = string
}

variable "project_id" {
  type    = string
}

variable "gke_pods_secondary_ips" {
  type    = string
  default = "us-central1-01-gke-01-pods"
}

variable "gke_services_secondary_ips" {
  type    = string
  default = "us-central1-01-gke-01-services"
}

terraform {
  required_version = ">= 0.12"
}

provider "google" {
  credentials = var.GCP_JSON_KEY
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = var.project_id
  name                       = "ddm-drone-pipeline"
  region                     = var.location
  logging_service            = "none"
  monitoring_service         = "none"

//  zones                      = ["us-central1-a", "us-central1-b", "us-central1-f"]
  zones                      = ["us-central1-a"]
  network                    = google_compute_network.kubernetes_vpc_network.name
  subnetwork                 = google_compute_subnetwork.kubernetes_subnetwork.name
  ip_range_pods              = var.gke_pods_secondary_ips
  ip_range_services          = var.gke_services_secondary_ips
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = true
  create_service_account     = false
  remove_default_node_pool   = true

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "n1-standard-2"
      min_count          = 1
      max_count          = 1
      local_ssd_count    = 0
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = false
      preemptible        = true
      initial_node_count = 1
    }
  ]
}

resource "google_compute_network" "kubernetes_vpc_network" {
  name = "ddm-drone-pipeline-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "kubernetes_subnetwork" {
  name          = "ddm-drone-pipeline-subnetwork"
  ip_cidr_range = "10.0.0.0/9"
  region        = var.location
  network       = google_compute_network.kubernetes_vpc_network.self_link
  secondary_ip_range {
    range_name    = var.gke_pods_secondary_ips
    ip_cidr_range = "172.16.0.0/20"
  }
  secondary_ip_range {
    range_name    = var.gke_services_secondary_ips
    ip_cidr_range = "172.17.0.0/20"
  }
}
