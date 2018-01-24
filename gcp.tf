variable "project" {}
variable "region" {}
variable "home_ip" {}
variable "user" {}

variable "do_token" {}

provider "google" {
  credentials = "${file(".terraform/account.json")}"
  project     = "${var.project}"
  region      = "${var.region}"
}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "google_compute_firewall" "home-ssh" {
  name = "home-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

    source_ranges = ["${var.home_ip}"]
}

resource "google_compute_firewall" "home-jenkins" {
  name = "home-jenkins"
  network = "default"

  allow {
    protocol = "tcp"
    ports = ["8080"]
  }

    source_ranges = ["${var.home_ip}"]
}

resource "google_compute_address" "ci-server" {
  name = "ci-server"
}

// Create a new instance
resource "google_compute_instance" "ci-server" {
  name = "ci-server"
  machine_type = "f1-micro"
  zone = "us-central1-a"
   
  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = "${google_compute_address.ci-server.address}"
    }
  }

  metadata {
    sshKeys = "${var.user}:${file("~/.ssh/id_rsa.pub")}"
  }

  service_account {
    scopes = ["storage-rw"]
  }

  provisioner "remote-exec" {
    inline = [
    "docker run -d \\",
      "-p 8080:8080 -p 50000:50000 \\",
      "-v jenkins_home:/var/jenkins_home \\",
      "--name jenkins jenkins/jenkins:lts"
    ]
    connection {
    type = "ssh"
    user = "${var.user}"
    private_key = "${file("~/.ssh/id_rsa")}"
    }
  }

}

resource "digitalocean_ssh_key" "default" {
  name = "default"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "digitalocean_droplet" "timeball-app" {
  image = "coreos-stable"
  name = "timeball-app"
  region = "nyc1"
  size = "s-1vcpu-1gb"
  ssh_keys = [
    "${digitalocean_ssh_key.default.fingerprint}"
  ]
}

resource "digitalocean_floating_ip" "timeball-app" {
  droplet_id = "${digitalocean_droplet.timeball-app.id}"
  region = "${digitalocean_droplet.timeball-app.region}"
}

resource "digitalocean_firewall" "timeball-app" {
  name = "timeball-app"

  droplet_ids = ["${digitalocean_droplet.timeball-app.id}"]

  inbound_rule = [
    {
      protocol = "tcp",
      port_range = "22",
      source_addresses = ["${var.home_ip}"]
    }
  ]

  outbound_rule = [
    {
      protocol = "tcp",
      port_range = "1-65535",
      destination_addresses  = ["0.0.0.0/0", "::/0"]

    },
    {
      protocol = "udp",
      port_range = "1-65535",
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol = "icmp",
      port_range = "0"
    }
  ]
}
