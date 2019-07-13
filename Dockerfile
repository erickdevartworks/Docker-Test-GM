FROM ubuntu:16.04

MAINTAINER Erick DEV  <erickdevartworks@outlook.com>
LABEL maintainer="Erick DEV  <erickdevartworks@outlook.com>"

ENV S6_FIX_ATTRS_HIDDEN=1
ENV SRC_DIR /usr/local/src/gamblecoin
RUN echo "fs.file-max = 65535" > /etc/sysctl.conf

RUN apt-get update -y && apt-get install -y    git \
                       build-essential \
                       libtool \
		       wget \
                       autotools-dev \
                       automake \
                       pkg-config \
                       libssl-dev \
                       libevent-dev \
                       bsdmainutils \
                       libboost-system-dev \
                       libboost-filesystem-dev \
                       libboost-chrono-dev \
                       libboost-program-options-dev \
                       libboost-test-dev \
                       libboost-thread-dev \
                       software-properties-common \
                       libminiupnpc-dev \
                       libzmq3-dev \
                       libqt4-dev libprotobuf-dev protobuf-compiler\
                       python3 \
                       libboost-thread-dev libboost-dev libevent-1.4-2 \
                       libqrencode-dev libminiupnpc-dev git \
                       g++ \
                       make \
                       automake       
RUN apt-get update && apt-get install software-properties-common -y \
                      && add-apt-repository ppa:bitcoin/bitcoin \
		      && apt-get update -y \
		      && apt-get install libdb4.8-dev libdb4.8++-dev -y \
	              && wget https://github.com/GambleCoin-Project/GambleCoin/releases/download/1.1.4/gamblecoin-1.1.4-x86_64-linux-gnu.tar.gz \
                      && tar -zxvf /gamblecoin-1.1.4-x86_64-linux-gnu.tar.gz \
		      && strip gamblecoin-1.1.4/bin/gamblecoind gamblecoin-1.1.4/bin/gamblecoin-cli gamblecoin-1.1.4/bin/gamblecoin-tx \
		      && cp gamblecoin-1.1.4/bin/gamblecoind /usr/local/bin/ \
		      && cp gamblecoin-1.1.4/bin/gamblecoin-cli /usr/local/bin/ \
		      && cp gamblecoin-1.1.4/bin/gamblecoin-tx /usr/local/bin/
ENV GOSU_VERSION 1.7
RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		wget \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true \
	&& apt-get purge -y \
		ca-certificates \
		wget \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./bin /usr/local/bin

VOLUME ["/root/.gamblecoin"]

EXPOSE 12000 12000 12010 12010

WORKDIR /root/.gamblecoin

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["gmcn_oneshot"]
