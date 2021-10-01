FROM debian:buster@sha256:9b0a8c03b28d4fd2b57cc44e4a3d06b01d4237c8874015a1749837d517c38612 AS build

RUN apt-get -q update && env DEBIAN_FRONTEND=noninteractive apt-get -qy install --no-install-recommends ruby ruby-dev build-essential zlib1g-dev git ca-certificates
RUN gem install amber
ADD . /src
WORKDIR /src/amber
RUN amber rebuild

FROM registry.revolt.org/software/containers/apache2-base:no-masters@sha256:a0f48c6b1e8e88a79f532dd05363bba7ca49718c5907fdd729f09a14582f87cb

COPY --from=build /src/public /var/www/riseup.net/public
COPY provider.json /var/www/riseup.net
COPY docker/conf /tmp/conf
COPY docker/build.sh /tmp/build.sh

RUN /tmp/build.sh && rm /tmp/build.sh
