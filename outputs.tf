output "aws_ami" {
  value = module.webserver_module.image_id
}

output "ec2_public_ip" {
  value = module.webserver_module.server_public_ip
}