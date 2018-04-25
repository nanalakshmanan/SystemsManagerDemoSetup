variable "instance_profile" {
  type = "string"
}

variable "key_pair" {
  type = "string"
}

variable "instance_type" {
  type    = "string"
  default = "t2.micro"
}

variable "windows_ami_id" {
  type = "string"
}

variable "linux_ami_id" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

resource "aws_security_group" "rdp_access_group" {
  vpc_id      = "${var.vpc_id}"
  description = "Enable RDP access via port 3389"
  name        = "RDPAccess"

  ingress = {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
  }
}

resource "aws_security_group" "ssh_access_group" {
  vpc_id      = "${var.vpc_id}"
  description = "Enable SSH access via port 22"
  name        = "SSHAccess"

  ingress = {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
}

resource "aws_instance" "windows_instance" {
  count                = 5
  ami                  = "${var.windows_ami_id}"
  instance_type        = "${var.instance_type}"
  key_name             = "${var.key_pair}"
  iam_instance_profile = "${var.instance_profile}"
  security_groups      = ["${aws_security_group.rdp_access_group.name}"]

  tags = {
    "Name"             = "HRAppWindows"
    "HRAppEnvironment" = "Production"
    "Environment"      = "Production"
  }

  depends_on = ["aws_security_group.rdp_access_group"]
}

resource "aws_instance" "linux_instance" {
  count                = 5
  ami                  = "${var.linux_ami_id}"
  instance_type        = "${var.instance_type}"
  key_name             = "${var.key_pair}"
  iam_instance_profile = "${var.instance_profile}"
  security_groups      = ["${aws_security_group.ssh_access_group.name}"]

  tags = {
    "Name"             = "HRAppLinux"
    "HRAppEnvironment" = "Production"
    "Environment"      = "Production"
  }

  depends_on = ["aws_security_group.ssh_access_group"]
}
