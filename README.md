# droplet-setup
install all the requirements to run the lendingbot (https://github.com/BitBotFactory/poloniexlendingbot)

# lifecycle
```bash
cap production digitalocean:create_droplet
cap staging puppet
cap production digitalocean:destroy_droplet
```
