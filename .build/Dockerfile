FROM debian:12.5-slim

ARG OPENWRT_RELEASE

RUN apt-get update
RUN apt-get install -y build-essential clang flex bison g++ gawk \
    gettext git libncurses5-dev libssl-dev \
    python3-setuptools rsync swig unzip zlib1g-dev file wget

COPY src /mypackages/ifmqtoggle/src
COPY Makefile /mypackages/ifmqtoggle/Makefile
RUN git clone -b ${OPENWRT_RELEASE} https://git.openwrt.org/openwrt/openwrt.git /builder

RUN useradd -m buildbot
RUN chown -R buildbot:buildbot /mypackages
RUN chown -R buildbot:buildbot /builder
USER buildbot
WORKDIR /builder

RUN echo "src-link mypackages /mypackages" >> feeds.conf.default
RUN ./scripts/feeds update -a
RUN ./scripts/feeds install -a -p mypackages
RUN echo "CONFIG_PACKAGE_ifmqtoggle=y" > .config
RUN make defconfig
RUN make toolchain/install
RUN make package/ifmqtoggle/compile
