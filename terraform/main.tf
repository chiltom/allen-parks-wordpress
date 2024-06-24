resource "aws_security_group" "allen-wp-sg" {
  name   = "allen-wp-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "allen-wp-server" {
  ami                         = var.ec2_ami
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allen-wp-sg.id]
  key_name                    = var.ec2_key_name

  tags = {
    Name = "allen-wp-server"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = var.ssh_user
    private_key = file(var.private_key_path)
    timeout     = "4m"
  }

  provisioner "remote-exec" {
    inline = [
      "touch /home/ubuntu/demo-file-from-terraform.txt"
    ]
  }
}

resource "local_file" "hosts" {
  content = templatefile("${path.module}/hosts_template",
    {
      public_ipaddr = aws_instance.allen-wp-server.public_ip
      key_path      = var.private_key_path
      ansible_user  = var.ssh_user
    }
  )
  filename = "${path.module}/hosts"
}

