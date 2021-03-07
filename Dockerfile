FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
ENV CCNL_HOME /var/ccn-lite
ENV PATH "$PATH:$CCNL_HOME/build/bin"
ENV CCNL_PORT 9000
ENV USE_NFN 1

# install new packages.
RUN apt --yes update
RUN apt install --yes software-properties-common

# install new packages.
RUN apt --yes update
RUN apt install --yes wget 
RUN apt install --yes libssl-dev
RUN apt install --yes default-jre
RUN apt install --yes build-essential

# add cmake signing key.
RUN wget --retry-connrefused --waitretry=1 \
--read-timeout=20 --timeout=15 -t 0 --no-dns-cache \
--output-document "${HOME}/kitware.asc" https://apt.kitware.com/keys/kitware-archive-latest.asc
RUN apt-add-key "${HOME}/kitware.asc"
RUN rm "${HOME}/kitware.asc"

# add additional repositories.
RUN add-apt-repository --yes --no-update "deb https://apt.kitware.com/ubuntu/ bionic main"

RUN apt --yes update
RUN apt install --yes cmake

ADD . /var/ccn-lite
WORKDIR /var/ccn-lite
RUN mkdir build
RUN cd build && cmake ../src && make clean all

EXPOSE 9000/udp

# CMD ["/var/ccn-lite/bin/ccn-nfn-relay", "-s", "ndn2013", "-d", "test/ndntlv" "-v", "info", "-u", "$CCNL_PORT", "-x", "/tmp/ccn-lite-mgmt.sock"]
# CMD /var/ccn-lite/bin/ccn-lite-relay -s ndn2013 -d test/ndntlv -v info -u $CCNL_PORT -x /tmp/ccn-lite-mgmt.sock