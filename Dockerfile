FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -yy update && \
    apt-get -yy install build-essential clang flex bison g++ gawk \
                gcc-multilib g++-multilib gettext git libncurses5-dev libssl-dev \
                python3-setuptools rsync swig unzip zlib1g-dev file wget

RUN userdel -r ubuntu && \
    groupadd -r builder -g 1000 && useradd --no-log-init -m -u 1000 -r -g builder builder
USER builder
WORKDIR /home/builder
