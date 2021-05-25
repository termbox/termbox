FROM debian:10-slim
COPY . /termbox
WORKDIR /termbox
RUN apt update \
 && apt install -y lsb-release apt-transport-https ca-certificates wget \
 && wget -O /etc/apt/trusted.gpg.d/php.gpg 'https://packages.sury.org/php/apt.gpg' \
 && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | \
    tee /etc/apt/sources.list.d/php.list \
 && apt update \
 && apt install -y make gcc php7.4 php7.4-mbstring xvfb xterm xvkbd \
 && ./tests/run.sh
