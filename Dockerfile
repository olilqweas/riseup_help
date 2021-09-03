FROM debian:buster@sha256:df7d71b9a1ce0fa0b774f52ac7a0d966b483f0650185cc3594ff7d367d5c6a55 AS build

RUN apt-get -q update && env DEBIAN_FRONTEND=noninteractive apt-get -qy install --no-install-recommends ruby ruby-dev build-essential zlib1g-dev git ca-certificates
RUN gem install amber
ADD . /src
WORKDIR /src/amber
RUN amber rebuild

FROM registry.revolt.org/software/containers/apache2-base:no-masters@sha256:472608ee02a697e86fdd3a85971f7c7ae3ddc8a7b578dd0eba8d41d653132036

COPY --from=build /src/public /var/www/riseup.net/public
COPY provider.json /var/www/riseup.net
COPY docker/conf /tmp/conf
COPY docker/build.sh /tmp/build.sh

RUN /tmp/build.sh && rm /tmp/build.sh
