resource "aws_security_group" "myapp-sg" {
  name   = "myapp-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

data "aws_ami" "latest_ubuntu_image" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.image_name}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["${var.image_owner}"] # Canonical account ID
}


resource "aws_key_pair" "server-key" {
  key_name   = "server-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "myapp-server" {
  ami                         = data.aws_ami.latest_ubuntu_image.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  key_name                    = aws_key_pair.server-key.key_name

 connection {
     type        = "ssh"
     user = "ubuntu"
     private_key = file("${var.private_key_location}")
     host = "${self.public_ip}"
   }
 provisioner "file" {
   source = "index.html"
   destination = "/tmp/index.html"
 }

 provisioner "remote-exec" {
   inline = [ 
      "sudo apt update -y" ,
      "sudo apt install docker.io -y",
      "sudo apt install apache2 -y",
      "sudo cp /tmp/index.html /var/www/html/index.html",
      "sudo systemctl start docker",
      "sudo usermod -a -G docker ubuntu",
      "sudo docker run -d -p 8080:80 nginx"
    ]
 }

  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  tags = {
    Name = "${var.env_prefix}-server"
  }
}
