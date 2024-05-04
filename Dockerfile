FROM registry.revolt.org/software/containers/base-images:bullseye@sha256:a89e0a90c27ba213eed5d180e35ff78ab27c36e5ac392ad494b355b988e8c86f AS build

RUN apt-get -q update && env DEBIAN_FRONTEND=noninteractive apt-get -qy install --no-install-recommends ruby ruby-dev build-essential zlib1g-dev git ca-certificates
RUN gem install amber
ADD . /src
WORKDIR /src/amber
RUN amber rebuild

FROM registry.revolt.org/software/containers/apache2-base:no-masters@sha256:e6db9d076d412b0e7ecfea14cc8859e77415a1c0fa9c74de01a49ddc13880a9f

COPY --from=build /src/public /var/www/riseup.net/public
COPY provider.json /var/www/riseup.net
COPY docker/conf /tmp/conf
COPY docker/build.sh /tmp/build.sh

RUN /tmp/build.sh && rm /tmp/build.sh

EXPOSE 8080/tcp
