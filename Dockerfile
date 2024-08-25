FROM ubuntu:24.04 AS builder

ENV TZ=Asia/Taipei \
    DEBIAN_FRONTEND=noninteractive 

COPY . /tmp/test

RUN apt-get update && \
    apt-get install -y \
    mk-configure \
    make \
    clang \
    libbluetooth-dev \
    libdbus-1-dev \
    libdbus-glib-1-dev \
    libglib2.0-dev \
    libmagickwand-dev \
    libopenobex2-dev \
    libusb-dev 

RUN cd /tmp/test && \
    ./configure && \
    make
    
FROM ubuntu:24.04

ENV TZ=Asia/Taipei \
    DEBIAN_FRONTEND=noninteractive 

RUN apt-get update && \
    apt-get install -y \
    libglib2.0-0 \
    libmagickwand-6.q16-7t64 \
    libusb-0.1-4 \
    libdbus-glib-1-2 \
    obexftp && \
    apt-get purge bluez-obexd bluez-cups -y

COPY --chmod=555 --from=builder /tmp/test/src/obex-data-server /usr/bin

RUN  echo "#!/bin/bash chmod 777 /var/run/sdp; rm -rf /var/lib/bluetooth/*;hciconfig hci0 piscan;obexftpd -c ~/.obexftp -b" > /usr/bin/obex.sh && \
     chmod 755 /usr/bin/obex.sh

CMD ["/usr/bin/obex.sh"]
