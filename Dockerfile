FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -yy update && \
    apt-get -yy install build-essential ccache ecj fastjar file g++ gawk \
gettext git java-propose-classpath libelf-dev libncurses5-dev libpcre2-dev \
libncursesw5-dev libssl-dev python python2.7-dev python3 unzip wget \
python3-distutils python3-setuptools python3-dev rsync subversion \
swig time xsltproc zlib1g-dev

RUN groupadd -r builder -g 1000 && useradd --no-log-init -m -u 1000 -r -g builder builder
USER builder
WORKDIR /home/builder
