provider "google" {
  region = var.region
  zone = var.zone
  project = var.project_id

  credentials = file(var.credentials_file)
}

resource "random_pet" "random" {
}

locals {
  prefix = "${var.cluster_name}-${random_pet.random.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# resources
# ---------------------------------------------------------------------------------------------------------------------


resource "google_compute_network" "compute_network" {
  name = "${local.prefix}-network"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "firewall_jdbc" {
  name = "${local.prefix}-allow-jdbc"
  network = google_compute_network.compute_network.self_link

  allow {
    protocol = "tcp"
    ports = [var.jdbc_port]
  }
}

resource "google_compute_firewall" "firewall_ui" {
  name = "${local.prefix}-allow-ui"
  network = google_compute_network.compute_network.self_link

  allow {
    protocol = "tcp"
    ports = ["8080"]
  }
}

resource "google_compute_firewall" "firewall_ssh" {
  name = "${local.prefix}-allow-ssh"
  network = google_compute_network.compute_network.self_link

  allow {
    protocol = "tcp"
    ports = ["22"]
  }
}

resource "google_compute_health_check" "health_check" {
  name = "${local.prefix}-health-check"

  http_health_check {
    port = "8080"
    request_path = "/health?ready=1"
  }
}

resource "google_compute_instance" "node_instances" {

  count = var.node_count

  name = "${local.prefix}-node-${count.index}"
  machine_type = var.node_machine_type
  min_cpu_platform = "Intel Skylake"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
      size = var.os_disk_size
      type = "pd-ssd"
    }
  }

  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network = google_compute_network.compute_network.self_link

    access_config {}
  }

}

resource "google_compute_instance_group" "node_instance_group" {
  name = "${local.prefix}-node-group"

  instances = google_compute_instance.node_instances.*.self_link

  zone = var.zone
}

resource "google_compute_region_backend_service" "backend_service" {
  name = "${local.prefix}-backend-service"
  health_checks = [google_compute_health_check.health_check.self_link]
  region = var.region

  backend {
    group = google_compute_instance_group.node_instance_group.self_link
  }

}

resource "google_compute_forwarding_rule" "forwarding_rule" {
  name = "${local.prefix}-forwarding-rule"
  load_balancing_scheme = "INTERNAL"
  ip_protocol = "TCP"
  region = var.region
  ports = [var.jdbc_port]
  network = google_compute_network.compute_network.self_link
  backend_service = google_compute_region_backend_service.backend_service.self_link
}


resource "google_compute_instance" "client_instances" {

  count = var.client_count

  name = "${local.prefix}-client-${count.index}"
  machine_type = var.client_machine_type
  min_cpu_platform = "Intel Skylake"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
      size = var.os_disk_size
      type = "pd-ssd"
    }
  }

  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network = google_compute_network.compute_network.self_link

    access_config {}
  }

}

# ---------------------------------------------------------------------------------------------------------------------
# null resources
# ---------------------------------------------------------------------------------------------------------------------

resource "null_resource" "prep_nodes" {

  count = var.node_count

  depends_on = [
    google_compute_firewall.firewall_ssh,
    google_compute_instance.node_instances
  ]

  connection {
    user = var.user
    host = element(google_compute_instance.node_instances.*.network_interface.0.access_config.0.nat_ip, count.index)
    private_key = file(var.private_key_path)
    timeout = "2m"
  }


  provisioner "remote-exec" {
    scripts = ["${path.root}/scripts/startup.sh"]
  }

  provisioner "file" {
    source = "${path.root}/scripts/disks.sh"
    destination = "/tmp/disks.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/disks.sh",
      "/tmp/disks.sh /dev/nvme0n1"
    ]
  }

  provisioner "file" {
    source = "${path.root}/scripts/node-install-crdb.sh"
    destination = "/tmp/node-install-crdb.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/node-install-crdb.sh",
      "/tmp/node-install-crdb.sh"
    ]
  }

  provisioner "remote-exec" {
    scripts = ["${path.root}/scripts/node-ready.sh"]
  }


  provisioner "remote-exec" {
    inline = ["sleep ${var.sleep}"]
  }

}


resource "null_resource" "prep_clients" {

  count = var.client_count

  depends_on = [
    google_compute_firewall.firewall_ssh,
    google_compute_instance.client_instances
  ]

  connection {
    user = var.user
    host = element(google_compute_instance.client_instances.*.network_interface.0.access_config.0.nat_ip, count.index)
    private_key = file(var.private_key_path)
    timeout = "2m"
  }

  provisioner "remote-exec" {
    scripts = ["${path.root}/scripts/startup.sh",
      "${path.root}/scripts/client-build.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = ["sleep ${var.sleep}"]
  }
}
