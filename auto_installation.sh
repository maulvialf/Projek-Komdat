sudo apt-get install software-properties-common
sudo add-apt-repository ppa:brightbox/ruby-ng
sudo apt-get update


sudo apt-get install ruby2.4 ruby2.4-dev zlib1g-dev libxml2-dev \
                       libsqlite3-dev postgresql-9.5 libpq-dev \
                       libxmlsec1-dev curl make g++


curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs build-essential

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn=1.10.1-1

sudo -u postgres createuser $USER
sudo -u postgres psql -c "alter user $USER with superuser" postgres


gem install bundler -v 1.13.6