FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

# set environment variables.
ENV CCNL_HOME /var/ccn-lite
ENV CS /var/content-store/
ENV PACPROTO ndn2013
ENV CCNL_PORT 9000

# append ccn lite binaries to path.
ENV PATH "${PATH}:${CCNL_HOME}/build/bin"

# install new packages.
RUN apt --yes update
RUN apt install --yes software-properties-common
RUN add-apt-repository --yes --no-update  "deb http://security.ubuntu.com/ubuntu xenial-security main"

# install new packages.
RUN apt --yes update
RUN apt full-upgrade --fix-missing --yes
RUN apt install --yes apt-utils
RUN apt install --yes pkg-config
RUN apt install --yes git
RUN apt install --yes git-core
RUN apt install --yes wget
RUN apt install --yes libssl-dev
RUN apt install --yes default-jre
RUN apt install --yes build-essential
RUN apt install --yes iproute2

# add cmake signing key.
RUN wget --retry-connrefused --waitretry=1 \
--read-timeout=20 --timeout=15 -t 0 --no-dns-cache \
--output-document "${HOME}/kitware.asc" https://apt.kitware.com/keys/kitware-archive-latest.asc
RUN apt-key add "${HOME}/kitware.asc"
RUN rm "${HOME}/kitware.asc"

# add additional repositories.
RUN add-apt-repository --yes --no-update "deb https://apt.kitware.com/ubuntu/ bionic main"

# install new packages.
RUN apt --yes update
RUN apt install --yes cmake

# get the ccn lite package from github.
WORKDIR /var
RUN git clone https://github.com/cn-uofbasel/ccn-lite.git

# create content store directory.
WORKDIR ${CS}

# build ccn lite.
WORKDIR /var/ccn-lite/build
RUN cmake                           \
    -D USE_NFN=1                    \
    -D USE_FRAG=0                   \
    -D USE_MGMT=1                   \
    -D USE_IPV4=1                   \
    -D USE_IPV6=1                   \
    -D USE_DEBUG=1                  \
    -D USE_STATS=1                  \
    -D USE_LOGGING=1                \
    -D USE_HMAC256=1                \
    -D USE_DUP_CHECK=1              \
    -D USE_LINKLAYER=1              \
    -D USE_CCNxDIGEST=1             \
    -D USE_UNIXSOCKET=1             \
    -D USE_HTTP_STATUS=1            \
    -D USE_DEBUG_MALLOC=1           \
    -D NEEDS_PACKET_CRAFTING=1      \
    -D NEEDS_PREFIX_MATCHING=1      \
    -S ../src                       
RUN make clean all

# create a ccn relay.
CMD ccn-lite-relay -s ${PACPROTO} -d ${CS} -v trace -u ${CCNL_PORT} -x /tmp/ccnl-relay.sock
