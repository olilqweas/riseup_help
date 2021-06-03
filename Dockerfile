FROM debian@sha256:87ed8e3a7b251eef42c2e4251f95ae3c5f8c4c0a64900f19cc532d0a42aa7107 AS build
RUN apt-get -q update && env DEBIAN_FRONTEND=noninteractive apt-get -qy install --no-install-recommends ruby ruby-dev build-essential zlib1g-dev git ca-certificates
RUN gem install amber
ADD . /src
WORKDIR /src/amber
RUN amber rebuild

FROM registry.revolt.org/software/containers/apache2-base:@sha256:b8f3716ac3193193f9510cb6539cbb346233bb2784706f2913502106676cdcef

COPY --from=build /src/public /var/www/riseup.net/public
COPY provider.json /var/www/riseup.net
COPY docker/conf /tmp/conf
COPY docker/build.sh /tmp/build.sh

RUN /tmp/build.sh && rm /tmp/build.sh
