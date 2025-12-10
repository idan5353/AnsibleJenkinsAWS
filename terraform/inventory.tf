resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tftpl", {
    web_servers      = aws_instance.web[*].public_ip
    private_key_path = var.private_key_path
  })
  filename = "${path.module}/../ansible/inventory.ini"

  depends_on = [aws_instance.web]
}
