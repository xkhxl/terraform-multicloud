output "gcp_web_ip" {
  description = "Public IP of GCP web VM"
  value       = google_compute_instance.gcp_web.network_interface[0].access_config[0].nat_ip
}

output "gcp_web_url" {
  description = "Quick URL to test in browser"
  value       = "http://${google_compute_instance.gcp_web.network_interface[0].access_config[0].nat_ip}"
}
output "aws_web_ip" {
  description = "Public IP of AWS EC2"
  value       = aws_instance.aws_web.public_ip
}

output "aws_web_url" {
  description = "Quick URL to test in browser"
  value       = "http://${aws_instance.aws_web.public_ip}"
}
