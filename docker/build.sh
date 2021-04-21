#!/bin/sh
#
# Install script for riseup.net inside a Docker container.
#
# The installation procedure requires installing some
# dedicated packages, so we have split it out to a script
# for legibility.

# Packages that are only used to build the site. These will be
# removed once we're done.
BUILD_PACKAGES="rsync git"

# Packages required to serve the website and run the services.
PACKAGES="ruby bundler"

APACHE_MODULES_ENABLE="
	headers
	rewrite
	negotiation
	proxy
	proxy_http
        passenger
"

# The default bitnami/minideb image defines an 'install_packages'
# command which is just a convenient helper. Define our own in
# case we are using some other Debian image.
if [ "x$(which install_packages)" = "x" ]; then
    install_packages() {
        env DEBIAN_FRONTEND=noninteractive apt-get install -qqy --no-install-recommends "$@"
    }
fi

set -e
umask 022

apt-get -q update
install_packages ${BUILD_PACKAGES} ${PACKAGES}

chmod -R go-w /tmp/conf
rsync -a /tmp/conf/ /etc/

# Setup Apache.
a2enmod -q ${APACHE_MODULES_ENABLE}

git clone https://0xacab.org/liberate/bitaddressq.git /var/www/bitaddressq
cd /var/www/bitaddressq
/usr/bin/bundle install --deployment

# Make sure that files are readable.
chmod -R a+rX /var/www/riseup.net
chmod -R a+rX /var/www/bitaddressq

# Remove packages used for installation.
apt-get remove -y --purge ${BUILD_PACKAGES}
apt-get autoremove -y
apt-get clean
rm -fr /var/lib/apt/lists/*
rm -fr /tmp/conf
