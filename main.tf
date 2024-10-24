provider "aws" {
    region = "eu-north-1"  
}

resource "aws_instance" "foo" {
  ami           = "ami-08eb150f611ca277f" # us-west-2
  instance_type = "t2.micro"
  tags = {
      Name = "my_instance"
  }
}
