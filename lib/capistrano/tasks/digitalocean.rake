require "rest-client"
require "yml-secrets"

namespace :digitalocean do

  desc "create a droplet through the API"
  task :create_droplet do
    secrets = Secrets::Secret.new "config/digitalocean.yml"
    url = "https://api.digitalocean.com/v2/droplets"
    body = {
      name: secrets.digitalocean.name, #hostname of the new droplet
      region: secrets.digitalocean.region, #ams3
      size: secrets.digitalocean.size, #512mb
      image: secrets.digitalocean.image, #ubuntu-14-04-x64
      ssh_keys: secrets.digitalocean.ssh_keys, #[307676, 322283]
      user_data: File.read(secrets.digitalocean.user_data), #"config/user_data.yml"
    }
    headers = {
      Authorization: "Bearer #{secrets.digitalocean.token}"
    }
    creation_response = JSON.parse(RestClient.post(url, body, headers))
    response = {}
    p "Creating droplet..."
    loop do
      sleep 5
      response = JSON.parse(RestClient.get("#{url}/#{creation_response["droplet"]["id"]}", headers))
      break if response["droplet"]["status"] == "active"
    end
    p "droplet created", response
    secrets.digitalocean.droplet_ip = response["droplet"]["networks"]["v4"][0]["ip_address"]
    secrets.digitalocean.droplet_id = response["droplet"]["id"]
  end

  desc "destroy the droplet through the API"
  task :destroy_droplet do
    secrets = Secrets::Secret.new "config/digitalocean.yml"
    droplet_id = secrets.digitalocean.droplet_id
    url = "https://api.digitalocean.com/v2/droplets/#{droplet_id}"
    headers = {
      Authorization: "Bearer #{secrets.digitalocean.token}"
    }
    deletion_reponse = JSON.parse(RestClient.delete(url, headers))
    p "Destroying droplet..."
    p deletion_reponse
    secrets.digitalocean.droplet_ip = ""
    secrets.digitalocean.droplet_id = ""
  end

end
