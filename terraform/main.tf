provider "aws" {
  region                    = "${var.aws_region}"
  profile                   = "${var.aws_profile}"
}

resource "aws_instance" "squid_instance" {
  ami             = "ami-759bc50a"
  instance_type   = "t2.micro"
  key_name        = "${aws_key_pair.squid_key.key_name}"

  security_groups = [
    "${aws_security_group.allow_inbound.name}",
    "${aws_security_group.allow_outbound.name}"
  ]

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "DEBIAN_FRONTEND=noninteractive sudo apt -yq install squid",
      "sudo mkdir -p /squid3/logs",
      "sudo mkdir -p /squid3/conf",
      "sudo mkdir -p /squid3/users",
      "sudo chown -R ubuntu:ubuntu /squid3"
    ]

    connection {
      type          = "ssh"
      user          = "ubuntu"
      private_key   = "${file("./squid_ec2")}"
    }
  }

  provisioner "file" {
    source      = "conf/squid.conf"
    destination = "/squid3/conf/squid.conf"

    connection {
      type          = "ssh"
      user          = "ubuntu"
      private_key   = "${file("./squid_ec2")}"
    }
  }

  provisioner "file" {
    source      = "users/passwd"
    destination = "/squid3/users/passwd"

    connection {
      type          = "ssh"
      user          = "ubuntu"
      private_key   = "${file("./squid_ec2")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chown -R proxy:proxy /squid3",
      "sudo chmod -R 755 /squid3",
      "sudo chmod -R 644 /squid3/conf/squid.conf"
    ]

    connection {
      type          = "ssh"
      user          = "ubuntu"
      private_key   = "${file("./squid_ec2")}"
    }
  }

  provisioner "remote-exec" {
    script = "./start-squid.sh"

    connection {
      type          = "ssh"
      user          = "ubuntu"
      private_key   = "${file("./squid_ec2")}"
    }
  }

  tags {
    Name = "squid-instance"
  }
}

resource "aws_eip" "squid_eip" {
  instance    = "${aws_instance.squid_instance.id}"
}

resource "aws_security_group" "allow_inbound" {
  name        = "allow-inbound"
  description = "Allow SSH and HTTP inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_outbound" {
  name        = "allow-all-outbound"
  description = "Allow all outbound traffic"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "squid_key" {
  key_name   = "squid_key"
  public_key = "${file("./squid_ec2.pub")}"
}
