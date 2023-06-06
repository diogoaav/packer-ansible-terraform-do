# Create managed MySQL database
resource "digitalocean_database_cluster" "mysql_cluster" {
  name      = "mysql-wordpress"
  engine    = "mysql"
  region    = "nyc3"
  version   = "8"
  size      = "db-s-1vcpu-1gb"
  node_count = 1
  tags      = ["mysql"]
}
output "mysql_cluster_info" {
  value = {
    host     = digitalocean_database_cluster.mysql_cluster.host
    port     = digitalocean_database_cluster.mysql_cluster.port
    user     = digitalocean_database_cluster.mysql_cluster.user
    password = digitalocean_database_cluster.mysql_cluster.password
  }
  sensitive  = true
}
