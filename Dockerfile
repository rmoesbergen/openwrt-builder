FROM ubuntu:18.04
RUN apt-get -yy update && \
    apt-get -yy install subversion build-essential libncurses5-dev zlib1g-dev gawk git ccache gettext libssl-dev xsltproc zip wget file python3 rsync nano
RUN groupadd -r builder -g 1000 && useradd --no-log-init -m -u 1000 -r -g builder builder
USER builder
WORKDIR /home/builder
