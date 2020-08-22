resource "aws_instance" "cyndaquil" {
  ami           = data.aws_ami.ubuntu-bionic.id
  instance_type = "t3.medium"
  key_name      = aws_key_pair.home.key_name
  security_groups = [
    aws_security_group.https.name,
    aws_security_group.http-ssh.name
  ]


  iam_instance_profile = aws_iam_instance_profile.cyndaquil.name

  provisioner "remote-exec" {
    connection {
      user    = "ubuntu"
      host    = self.public_ip
      timeout = "15m"
    }

    inline = [
      "wget https://github.com/advantageous/systemd-cloud-watch/releases/download/v0.2.1/systemd-cloud-watch_linux",
      "chmod +x ./systemd-cloud-watch_linux",
      "echo 'log_group = \"cyndaquil-ec2-journald\"' >> .cwconfig",
      "sudo sh -c \"echo '[Unit]\nDescription=journald-cloudwatch-logs\nWants=basic.target\nAfter=basic.target network.target\n[Service]\nUser=nobody\nGroup=nobody\nExecStart=/home/ubuntu/systemd-cloud-watch_linux /home/ubuntu/.cwconfig\nKillMode=process\nRestart=on-failure\nRestartSec=42s' > /etc/systemd/system/cw.service\"",

      "sudo systemctl daemon-reload",
      "sudo systemctl enable cw",

      #"sudo reboot &",
    ]
  }

  provisioner "remote-exec" {
    connection {
      user    = "ubuntu"
      host    = self.public_ip
      timeout = "15m"
    }

    inline = [
      "wget https://github.com/mholt/caddy/releases/download/v1.0.0/caddy_v1.0.0_linux_amd64.tar.gz",
      "tar -xvf caddy_v1.0.0_linux_amd64.tar.gz caddy",
      "echo -e 'https://api.raid.network {\n proxy / localhost:4000\n tls joao.anes@gmail.com\n}\nhttps://ws.raid.network {\n proxy /ws localhost:4000/ws\n websocket\n}' >> ./Caddyfile",
      "sudo sh -c \"echo '[Unit]\nDescription=caddy\nWants=basic.target\nAfter=basic.target network.target\n[Service]\nUser=root\nExecStart=/home/ubuntu/caddy -agree -conf /home/ubuntu/Caddyfile\nKillMode=process\nRestart=on-failure\nRestartSec=42s' > /etc/systemd/system/caddy.service\"",

      "sudo systemctl daemon-reload",
      "sudo systemctl enable caddy",
    ]
  }
}

resource "aws_iam_instance_profile" "cyndaquil" {
  name = "cyndaquil_profile"
  role = aws_iam_role.cyndaquil_ec2.name
}

