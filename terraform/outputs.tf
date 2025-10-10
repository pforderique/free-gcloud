output "external_ip" {
  description = "Ephemeral external IP of the VM"
  value       = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}

output "ssh_command" {
  description = "Quick SSH command"
  value       = "gcloud compute ssh ${google_compute_instance.vm.name} --zone=${google_compute_instance.vm.zone}"
}

output "http_url" {
  description = "HTTP test URL"
  value       = "http://${google_compute_instance.vm.network_interface[0].access_config[0].nat_ip}/"
}
