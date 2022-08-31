FROM registry.revolt.org/software/containers/base-images:bullseye@sha256:446effbe45d93c44ad2b28e14bcde195310c19930b6cb11f1056c12bb3e8051f AS build

RUN apt-get -q update && env DEBIAN_FRONTEND=noninteractive apt-get -qy install --no-install-recommends ruby ruby-dev build-essential zlib1g-dev git ca-certificates
RUN gem install amber
ADD . /src
WORKDIR /src/amber
RUN amber rebuild

FROM registry.revolt.org/software/containers/apache2-base:no-masters@sha256:bc3b4091b39f52f0385efe22750002e0fde3bac20e79bbcfbb7277c3e19df6cd

COPY --from=build /src/public /var/www/riseup.net/public
COPY provider.json /var/www/riseup.net
COPY docker/conf /tmp/conf
COPY docker/build.sh /tmp/build.sh

RUN /tmp/build.sh && rm /tmp/build.sh

EXPOSE 8080/tcp
