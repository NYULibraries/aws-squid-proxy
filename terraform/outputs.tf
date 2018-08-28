output "server-ip" {
  value = "${aws_eip.squid_eip.public_ip}"
}
