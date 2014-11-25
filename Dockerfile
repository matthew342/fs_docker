FROM debian:wheezy

ENV FREESWITCH_PATH /usr/local/freeswitch
ENV FREESWITCH_SRC_PATH /usr/local/src/freeswitch

ENV 	DEBIAN_FRONTEND noninteractive
WORKDIR /usr/local/src
COPY	modules.conf /tmp/modules.conf

RUN 	BUILD_DEPS="autoconf automake devscripts libtool make git-core g++" && \
	apt-get update && apt-get install -y --no-install-recommends $BUILD_DEPS  \
		gawk python-dev gawk pkg-config libtiff5-dev libperl-dev libgdbm-dev libdb-dev gettext libssl-dev \
		libcurl4-openssl-dev libpcre3-dev libspeex-dev libspeexdsp-dev libsqlite3-dev libedit-dev libldns-dev libpq-dev && \
	env GIT_SSL_NO_VERIFY=true git clone -b v1.4 https://freeswitch.org/stash/scm/fs/freeswitch.git && \
	cd /usr/local/src/freeswitch && \
	./bootstrap.sh -j && \
	# replace the standard modules.conf with your custom file
	cp -f /tmp/modules.conf ./modules.conf && \
	./configure --enable-core-pgsql-support && \
	make && make install && \
	rm -r -f /usr/local/src/ && \
	apt-get -f -y install && \
	apt-get purge -y $BUILD_DEPS && \
    	apt-get autoremove -y

ENV 	DEBIAN_FRONTEND dialog && \
ENV PATH ${FREESWITCH_PATH}/bin:$PATH

RUN useradd --system --home-dir ${FREESWITCH_PATH} --comment "FreeSWITCH Voice Platform" --groups daemon freeswitch && \
  	chown -R freeswitch:daemon ${FREESWITCH_PATH} && \
  	chmod -R ug=rwX,o= ${FREESWITCH_PATH} && \
  	chmod -R u=rwx,g=rx ${FREESWITCH_PATH}/bin/*

CMD  ${FREESWITCH_PATH}/bin/freeswitch
