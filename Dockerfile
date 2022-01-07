FROM debian:buster@sha256:94ccfd1c5115a6903cbb415f043a0b04e307be3f37b768cf6d6d3edff0021da3 AS build

RUN apt-get -q update && env DEBIAN_FRONTEND=noninteractive apt-get -qy install --no-install-recommends ruby ruby-dev build-essential zlib1g-dev git ca-certificates
RUN gem install amber
ADD . /src
WORKDIR /src/amber
RUN amber rebuild

FROM registry.revolt.org/software/containers/apache2-base:no-masters@sha256:82cf89beacf1ef5973d5f2316e7035741481b76695cd43941449967b6271bd93

COPY --from=build /src/public /var/www/riseup.net/public
COPY provider.json /var/www/riseup.net
COPY docker/conf /tmp/conf
COPY docker/build.sh /tmp/build.sh

RUN /tmp/build.sh && rm /tmp/build.sh

EXPOSE 8080/tcp
