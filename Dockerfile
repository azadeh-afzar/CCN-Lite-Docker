FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
ENV CCNL_HOME /var/ccn-lite
ENV PATH "$PATH:$CCNL_HOME/build/bin"
ENV CCNL_PORT 9000
ENV USE_NFN 1

# install new packages.
RUN apt --yes update
RUN apt install --yes software-properties-common
RUN add-apt-repository --yes --no-update  "deb http://security.ubuntu.com/ubuntu xenial-security main"

# install new packages.
RUN apt --yes update
RUN apt install --yes git
RUN apt install --yes git-core
RUN apt install --yes wget 
RUN apt install --yes libssl-dev
RUN apt install --yes default-jre
RUN apt install --yes build-essential

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

# build ccn lite
WORKDIR /var/ccn-lite/build
RUN cmake ../src
RUN make clean all

# set protocol:port
EXPOSE 9000/udp

# CMD ["/var/ccn-lite/bin/ccn-nfn-relay", "-s", "ndn2013", "-d", "test/ndntlv" "-v", "info", "-u", "$CCNL_PORT", "-x", "/tmp/ccn-lite-mgmt.sock"]
# CMD /var/ccn-lite/bin/ccn-lite-relay -s ndn2013 -d test/ndntlv -v info -u $CCNL_PORT -x /tmp/ccn-lite-mgmt.sock