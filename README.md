# droplet-setup
install all the requirements to run the trading server

# lifecycle
```bash
cap production digitalocean:create_droplet
cap staging puppet
cap production digitalocean:destroy_droplet
```
