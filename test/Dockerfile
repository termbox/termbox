FROM debian:10-slim
COPY . /termbox
WORKDIR /termbox
RUN apt-get update \
 && apt-get install -y make gcc xvfb xterm x11-apps imagemagick xz-utils ncat \
 && ./test/run.sh
