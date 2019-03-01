# Define SSH key pair for our instances
resource "aws_key_pair" "default" {
  key_name = "vpctestkeypair"
  public_key = "${file("${var.key_path}")}"
}

# Define webserver inside the public subnet
resource "aws_instance" "frontend" {
   ami  = "${var.ami}"
   instance_type = "t1.micro"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.public-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.sgfrontend.id}"]
   associate_public_ip_address = true
   source_dest_check = false
   user_data = "${file("frontend.sh")}"

  tags {
    Name = "frontend"
  }
}

# Define database inside the private subnet
resource "aws_instance" "backend" {
   ami  = "${var.ami}"
   instance_type = "t1.micro"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.private-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.sgbackend.id}"]
   source_dest_check = false
   user_data = "${file("backend.sh")}"
  tags {
    Name = "backend"
  }
}
