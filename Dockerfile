FROM registry.revolt.org/software/containers/base-images:bullseye@sha256:f5950a81f04bcb00518b885ef11a9af10036dbfccc10d2aa34d83a9942a118d6 AS build

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
