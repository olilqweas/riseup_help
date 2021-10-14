FROM debian:buster@sha256:f9182ead292f45165f4a851e5ff98ea0800e172ccedce7d17764ffaae5ed4d6e AS build

RUN apt-get -q update && env DEBIAN_FRONTEND=noninteractive apt-get -qy install --no-install-recommends ruby ruby-dev build-essential zlib1g-dev git ca-certificates
RUN gem install amber
ADD . /src
WORKDIR /src/amber
RUN amber rebuild

FROM registry.revolt.org/software/containers/apache2-base:no-masters@sha256:a69d4c0e87a548e01070e255be9fb211cc98e5cffb1fae28fa348e060b08eccc

COPY --from=build /src/public /var/www/riseup.net/public
COPY provider.json /var/www/riseup.net
COPY docker/conf /tmp/conf
COPY docker/build.sh /tmp/build.sh

RUN /tmp/build.sh && rm /tmp/build.sh
