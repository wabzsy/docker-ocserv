FROM alpine:3.6

MAINTAINER Xiaomo @ InkSec

ENV OC_VERSION 0.11.8

ENV Deps "curl g++ gnutls-dev libev-dev libnl3-dev libseccomp-dev linux-headers linux-pam-dev lz4-dev make readline-dev"

COPY conf /conf

COPY certs /certs

RUN 	set -x \
	&& apk add --update gnutls gnutls-utils iptables libev libintl libnl3 libseccomp lz4-libs readline linux-pam \
	&& apk add $Deps \
	&& mkdir -p /usr/src/ocserv \
	&& tar -xf /conf/ocserv-$OC_VERSION.tar.xz -C /usr/src/ocserv --strip-components=1 \
	&& cd /usr/src/ocserv \
	&& ./configure \
	&& make \
	&& make install \
	&& mkdir -p /etc/ocserv/config-per-group 	&& cd /conf \
	&& cp ocserv.conf /etc/ocserv/ \
	&& cat Groups >> /etc/ocserv/ocserv.conf 	&& cp Smart Global /etc/ocserv/config-per-group/ \
	&& apk del $Deps \
	&& rm -rf /usr/src/ocserv \
	&& rm -rf /var/cache/apk/* \
	&& rm -rf /conf

WORKDIR /etc/ocserv


COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 443

CMD ["ocserv", "-c", "/etc/ocserv/ocserv.conf", "-f"]

