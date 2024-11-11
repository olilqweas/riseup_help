FROM registry.revolt.org/software/containers/base-images:bullseye@sha256:909d86994f96d5e0594818e72e435b8a1465565681b7d6958f71daa74f3b2d39 AS build

RUN apt-get -q update && env DEBIAN_FRONTEND=noninteractive apt-get -qy install --no-install-recommends ruby ruby-dev build-essential zlib1g-dev git ca-certificates
RUN gem install amber
ADD . /src
WORKDIR /src/amber
RUN amber rebuild

FROM registry.revolt.org/software/containers/apache2-base:no-masters@sha256:89d5ddcacd4a7d31475921b3c458d6cccdef214e4bbdf3cb85130b0c1d7742dd

COPY --from=build /src/public /var/www/riseup.net/public
COPY provider.json /var/www/riseup.net
COPY docker/conf /tmp/conf
COPY docker/build.sh /tmp/build.sh

RUN /tmp/build.sh && rm /tmp/build.sh

EXPOSE 8080/tcp
