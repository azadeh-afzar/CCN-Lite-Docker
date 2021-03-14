FROM ubuntu:20.04

LABEL maintainer "Mohammad Mahdi Baghbani Pourvahid <MahdiBaghbani@protonmail.com>"

# set environment variables.
ENV DEBIAN_FRONTEND noninteractive
ENV CCNL_HOME /var/CCN-Lite
ENV CONTENT_STOR /var/content-store/
ENV PACPROTO ndn2013
ENV CCNL_PORT 9000

# append ccn lite binaries to path.
ENV PATH "${PATH}:${CCNL_HOME}/build/bin"

# install new packages.
RUN apt install --yes software-properties-common
RUN add-apt-repository --yes "deb http://security.ubuntu.com/ubuntu xenial-security main"

# install new packages.
RUN apt update &&           \
    apt install --yes       \
    apt-utils               \
    pkg-config              \
    git                     \
    git-core                \
    wget                    \
    libssl-dev              \
    default-jre             \
    build-essential         \
    iproute2                \
    net-tools

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

# create content store directory.
WORKDIR ${CONTENT_STOR}

# get the ccn lite package from github.
WORKDIR /var
RUN git clone https://gitlab.com/Azadeh-Afzar/Computer-Science/Networking/CCN-Lite.git

# checkout to desired branch.
WORKDIR ${CCNL_HOME}
RUN git checkout master

# build ccn lite.
WORKDIR ${CCNL_HOME}/build
RUN cmake ../src
RUN make clean all

# expose port.
EXPOSE ${CCNL_PORT}/udp

# create a ccn relay.
CMD ccn-lite-relay -s ${PACPROTO} -d ${CONTENT_STOR} -v trace -u ${CCNL_PORT} -x /tmp/ccnl-relay.sock
