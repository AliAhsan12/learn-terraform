provider "aws" {
  region = "us-east-1"
  access_key = "AKIAQ7FCKRU5ZWPEWJMP"
  secret_key = "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"
}

resource "aws_vpc" "dev-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "dev-vpc"
  }
}

resource "aws_subnet" "dev-subnet-1" {
  vpc_id = aws_vpc.dev-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    name = "dev-subnet-1"
  }
}

