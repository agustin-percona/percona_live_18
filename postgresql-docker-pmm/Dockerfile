# to build:
# docker build -t guriandoro/postgresql-pmm:1.0 .
FROM postgres:latest

RUN apt-get update; \
    apt-get -y install lsb-release wget;

RUN wget https://repo.percona.com/apt/percona-release_0.1-4.$(lsb_release -sc)_all.deb; \
    dpkg -i percona-release_0.1-4.$(lsb_release -sc)_all.deb; \
    apt-get update; \
    apt-get -y install pmm-client;

COPY configure-pmm-client.sh /usr/local/bin 
RUN chmod +x /usr/local/bin/configure-pmm-client.sh

