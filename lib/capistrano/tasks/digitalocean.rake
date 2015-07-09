require "rest-client"


def get_secrets
  secrets_file = "config/secrets.yml"
  YAML.load_file secrets_file
end


def save_secrets secrets
  secrets_file = "config/secrets.yml"
  File.open(secrets_file, "w") {|f| f.write secrets.to_yaml}
end


namespace :digitalocean do

  desc "create a droplet through the API"
  task :create_droplet do
    secrets = get_secrets()
    token = secrets["development"]["digitalocean_token"]
    url = "https://api.digitalocean.com/v2/droplets"
    body = {
      name: "basketball-ref-challenge.com",
      region: "ams3",
      size: "512mb",
      image: "ubuntu-14-04-x64",
      ssh_keys: [307676, 322283],
      user_data: File.read("config/user_data.yml"),
    }
    p body
    headers = {
      Authorization: "Bearer #{token}"
    }
    creation_response = JSON.parse(RestClient.post(url, body, headers))
    response = {}
    p "Creating droplet..."
    p creation_response
    loop do
      sleep 5
      response = JSON.parse(RestClient.get("#{url}/#{creation_response["droplet"]["id"]}", headers))
      break if response["droplet"]["status"] == "active"
    end
    p response
    secrets["development"]["droplet_ip"] = response["droplet"]["networks"]["v4"][0]["ip_address"]
    secrets["development"]["droplet_id"] = response["droplet"]["id"]
    save_secrets secrets
  end

  desc "destroy the droplet through the API"
  task :destroy_droplet do
    secrets = get_secrets()
    droplet_id = secrets["development"]["droplet_id"]
    token = secrets["development"]["digitalocean_token"]
    url = "https://api.digitalocean.com/v2/droplets/#{droplet_id}"
    headers = {
      Authorization: "Bearer #{token}"
    }
    RestClient.delete(url, headers)
    p "Destroying droplet..."
    secrets["development"]["droplet_ip"] = ""
    secrets["development"]["droplet_id"] = ""
    save_secrets secrets
  end

end
