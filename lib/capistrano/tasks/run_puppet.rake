desc "upload and run the puppet recipe"
task :puppet do
  on roles(:root) do |host|
    upload! "lib/puppet/Puppetfile", "Puppetfile"
    execute :r10k, "puppetfile check"
    execute :r10k, "puppetfile install"
    upload! "lib/puppet/recipe.pp", "recipe.pp"
    execute :puppet, "apply recipe.pp"
  end
end

desc "upload duckdns update script"
task :duckdns do
  on roles(:app) do |host|
    upload! "config/duckdns.sh", "duckdns.sh"
    execute "./duckdns.sh &> duckdns.log"
  end
end
