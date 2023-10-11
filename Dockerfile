FROM registry.revolt.org/software/containers/base-images:bullseye@sha256:20091deed62f9fd11c9d4e18d8d7813c5f7df292afa4fee98fe3d2d9009bd883 AS build

RUN apt-get -q update && env DEBIAN_FRONTEND=noninteractive apt-get -qy install --no-install-recommends ruby ruby-dev build-essential zlib1g-dev git ca-certificates
RUN gem install amber
ADD . /src
WORKDIR /src/amber
RUN amber rebuild

FROM registry.revolt.org/software/containers/apache2-base:no-masters@sha256:b975c417581869900edf3f4d912c32dbcbb3f2268179fa54b188c3d96bb9b2a3

COPY --from=build /src/public /var/www/riseup.net/public
COPY provider.json /var/www/riseup.net
COPY docker/conf /tmp/conf
COPY docker/build.sh /tmp/build.sh

RUN /tmp/build.sh && rm /tmp/build.sh

EXPOSE 8080/tcp
