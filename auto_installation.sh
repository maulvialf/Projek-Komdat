## depedency

sudo apt-get install software-properties-common
sudo add-apt-repository ppa:brightbox/ruby-ng
sudo apt-get update


sudo apt-get install -y ruby2.4 ruby2.4-dev zlib1g-dev libxml2-dev \
                       libsqlite3-dev postgresql-9.5 libpq-dev \
                       libxmlsec1-dev curl make g++


# install nodejs
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs build-essential

# install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn=1.10.1-1

# add user of psql
sudo -u postgres createuser $USER
sudo -u postgres psql -c "alter user $USER with superuser" postgres


# install bundler
gem install bundler -v 1.13.6

# go to canvas
cd canvas
bundle install
yarn install --pure-lockfile
# Sometimes you have to run this command twice if there is an error 
yarn install --pure-lockfile

# javascript versi coffe-script
sudo npm install -g coffee-script@1.6.2

## canvas