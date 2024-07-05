ARG OPENWRT_RELEASE
FROM openwrt/sdk:ath79-tiny-${OPENWRT_RELEASE}

COPY src /mypackages/ifmqtoggle/src
COPY Makefile /mypackages/ifmqtoggle/Makefile

RUN echo "src-link mypackages /mypackages" >> feeds.conf.default
RUN ./scripts/feeds update -a
RUN ./scripts/feeds install -a -p mypackages
RUN echo "CONFIG_PACKAGE_ifmqtoggle=y" > .config
RUN make defconfig
RUN make package/ifmqtoggle/compile
