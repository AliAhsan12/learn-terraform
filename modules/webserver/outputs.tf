output "image_id" {
  value = data.aws_ami.latest_ubuntu_image.id
}

output "server_public_ip" {
  value = aws_instance.myapp-server.public_ip
}