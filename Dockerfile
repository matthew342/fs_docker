FROM debian:wheezy

ENV FREESWITCH_PATH /usr/local/freeswitch
ENV FREESWITCH_SRC_PATH /usr/local/src/freeswitch

ENV 	DEBIAN_FRONTEND noninteractive
WORKDIR /usr/local/src
COPY	modules.conf /tmp/modules.conf
RUN 	apt-get update && apt-get install -y --no-install-recommends build-essential autoconf automake libtool \
			zlib1g-dev libjpeg-dev libncurses-dev libssl-dev libcurl4-openssl-dev python-dev libexpat-dev \
			libtiff-dev libx11-dev wget git && \
	 		git clone -b v1.4 https://freeswitch.org/stash/scm/fs/freeswitch.git && \
			cd /usr/local/src/freeswitch && \
			./bootstrap.sh -j && \
			# replace the standard modules.conf with your custom file
			cp -f /tmp/modules.conf ./modules.conf && \
			make && make install && \
			apt-get clean && rm -r -f /usr/local/src/

ENV 	DEBIAN_FRONTEND dialog && \
ENV PATH ${FREESWITCH_PATH}/bin:$PATH

RUN useradd --system --home-dir ${FREESWITCH_PATH} --comment "FreeSWITCH Voice Platform" --groups daemon freeswitch && \
  	chown -R freeswitch:daemon ${FREESWITCH_PATH} && \
  	chmod -R ug=rwX,o= ${FREESWITCH_PATH} && \
  	chmod -R u=rwx,g=rx ${FREESWITCH_PATH}/bin/*

CMD  ${FREESWITCH_PATH}/bin/freeswitch