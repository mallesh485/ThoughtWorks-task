provider "aws" {
region = "us-east-2"
access_key = "<your access_key>"
secret_key = "<your secret_key>"
}


resource "aws_instance" "web" {
  ami           = "ami-0a91cd140a1fc148a" # us-east-2, ubuntu-20
  instance_type = "t2.micro"
  key_name      = "<your pemfile name>"
  vpc_security_group_ids = ["${aws_security_group.webSG.id}"]
  tags = {
    Name = "remote-exec-provisioner"
  }
  
}

resource "null_resource" "copy_execute" {
  
    connection {
    type = "ssh"
    host = aws_instance.web.public_ip
    user = "ubuntu"
    private_key = file("<your pemfile name with .pem extension>")
    }

    provisioner "file" {
    source      = "tomcat.yml"
    destination = "/tmp/tomcat.yml"
  }

 
  
  
   provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install ansible -y",
      "ansible-playbook  '/tmp/tomcat.yml'"


    ]
  } 


 
   
  
  depends_on = [ aws_instance.web ]
  
  }

resource "aws_security_group" "webSG" {
  name        = "webSG"
  description = "Allow ssh  inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080  
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }
}
output "instance_public_ip_addr" {
  value = aws_instance.web.public_ip
}