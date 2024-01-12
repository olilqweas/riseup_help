FROM registry.revolt.org/software/containers/base-images:bullseye@sha256:5ff98efcc7f018c6996b4e81f6303c9f7f82231799b405bec03963b2ea5e9018 AS build

RUN apt-get -q update && env DEBIAN_FRONTEND=noninteractive apt-get -qy install --no-install-recommends ruby ruby-dev build-essential zlib1g-dev git ca-certificates
RUN gem install amber
ADD . /src
WORKDIR /src/amber
RUN amber rebuild

FROM registry.revolt.org/software/containers/apache2-base:no-masters@sha256:c3398b57309bbd64605f8a68edb3fc3135fcc899675222a2bfa864fb5bb08fa8

COPY --from=build /src/public /var/www/riseup.net/public
COPY provider.json /var/www/riseup.net
COPY docker/conf /tmp/conf
COPY docker/build.sh /tmp/build.sh

RUN /tmp/build.sh && rm /tmp/build.sh

EXPOSE 8080/tcp
