# Create Droplet from snapshot
resource "digitalocean_droplet" "wordpress" {
  name    = "droplet-wordpress"
  region  = "nyc3"
  image   = "133853609"
  size    = "s-1vcpu-1gb"
  backups = false
  ipv6    = true

}