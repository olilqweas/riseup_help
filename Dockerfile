FROM registry.revolt.org/software/containers/base-images:bullseye@sha256:d9ea70e72076c34629eeb9fa84b437aeca3baa1843ce1fe005188db381120f57 AS build

RUN apt-get -q update && env DEBIAN_FRONTEND=noninteractive apt-get -qy install --no-install-recommends ruby ruby-dev build-essential zlib1g-dev git ca-certificates
RUN gem install amber
ADD . /src
WORKDIR /src/amber
RUN amber rebuild

FROM registry.revolt.org/software/containers/apache2-base:s6@sha256:5f5472f7fc172a3c37f1e43c5f08ef56f3305ffc34c0d4d80d63bd92feb98c9b

COPY --from=build /src/public /var/www/riseup.net/public
COPY provider.json /var/www/riseup.net
COPY docker/conf /tmp/conf
COPY docker/build.sh /tmp/build.sh

RUN /tmp/build.sh && rm /tmp/build.sh

EXPOSE 8080/tcp
