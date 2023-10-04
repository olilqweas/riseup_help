FROM registry.revolt.org/software/containers/base-images:bullseye@sha256:68b3c8c3c00b2d72755472ffc64895caec9a3a3f64eeeaaa3c80f7c4c1d4b1a8 AS build

RUN apt-get -q update && env DEBIAN_FRONTEND=noninteractive apt-get -qy install --no-install-recommends ruby ruby-dev build-essential zlib1g-dev git ca-certificates
RUN gem install amber
ADD . /src
WORKDIR /src/amber
RUN amber rebuild

FROM registry.revolt.org/software/containers/apache2-base:no-masters@sha256:855d5603e71ecb8aa29ab9decc9004e30bfcf24606660180f68fd35c6180afec

COPY --from=build /src/public /var/www/riseup.net/public
COPY provider.json /var/www/riseup.net
COPY docker/conf /tmp/conf
COPY docker/build.sh /tmp/build.sh

RUN /tmp/build.sh && rm /tmp/build.sh

EXPOSE 8080/tcp
