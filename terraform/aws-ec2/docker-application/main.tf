resource "null_resource" "docker_setup" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = var.ec2_public_ip
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
    }

    inline = [
      "sudo apt update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "CODENAME=$(lsb_release -cs)",
      "echo 'deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $CODENAME stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt install -y docker-ce docker-ce-cli containerd.io || sudo apt-get install -y docker.io",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ubuntu",
      "sudo curl -L 'https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)' -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "docker --version",
      "docker-compose --version",
      "echo '=================================================='",
      "echo 'Docker and Docker Compose have been installed!'",
      "echo 'You may need to log out and log back in for group changes to take effect.'",
      "echo '=================================================='",
      "echo 'Download myweather-app application and bring up the docker-compose up'",
      "git clone https://github.com/vijai-veerapandian/myweather-app.git /home/ubuntu/app || true",
      "cd /home/ubuntu/app && sudo docker-compose up -d"
    ]
  }
}