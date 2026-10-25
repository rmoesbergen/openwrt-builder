FROM ubuntu:26.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -yy update && \
    apt-get -yy install bzip2 g++ gawk gcc git glibc-source libncurses-dev make file wget curl unzip rsync swig ncurses-term \
                gettext libssl-dev python3-setuptools zlib1g-dev

RUN userdel -r ubuntu && \
    groupadd -r builder -g 1000 && useradd --no-log-init -m -u 1000 -r -g builder builder
USER builder
WORKDIR /home/builder
