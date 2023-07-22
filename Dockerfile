FROM registry.revolt.org/software/containers/base-images:bullseye@sha256:d74225fd52412612e6d8f50277fb44997bc0a98376182a957105c6775b29922a AS build

RUN apt-get -q update && env DEBIAN_FRONTEND=noninteractive apt-get -qy install --no-install-recommends ruby ruby-dev build-essential zlib1g-dev git ca-certificates
RUN gem install amber
ADD . /src
WORKDIR /src/amber
RUN amber rebuild

FROM registry.revolt.org/software/containers/apache2-base:no-masters@sha256:e828fd39d704ae9d1a48ddc060fefa3d47cc090cf85fe3fbf9b3177e70b11bac

COPY --from=build /src/public /var/www/riseup.net/public
COPY provider.json /var/www/riseup.net
COPY docker/conf /tmp/conf
COPY docker/build.sh /tmp/build.sh

RUN /tmp/build.sh && rm /tmp/build.sh

EXPOSE 8080/tcp
