#!/bin/sh
#
# Install script for liberate.org inside a Docker container.
#
# The installation procedure requires installing some
# dedicated packages, so we have split it out to a script
# for legibility.

# Packages that are only used to build the site. These will be
# removed once we're done.
BUILD_PACKAGES="rsync"

# Packages required to serve the website and run the services.
PACKAGES=""

APACHE_MODULES_ENABLE="
	headers
	rewrite
	negotiation
	proxy
	proxy_http
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

# Make sure that files are readable.
chmod -R a+rX /var/www/riseup.net

# Remove packages used for installation.
apt-get remove -y --purge ${BUILD_PACKAGES}
apt-get autoremove -y
apt-get clean
rm -fr /var/lib/apt/lists/*
rm -fr /tmp/conf
