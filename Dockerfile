FROM docker.io/s390x/ubuntu:18.04
####
# Update the ubuntu image and load new s/w
####
RUN set -eux; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends 
 #   apt-get upgrade

RUN DEBIAN_FRONTEND="noninteractive" \
    apt-get -y install tzdata
RUN  set -eux; \
                \
    apt-get install -y wget         \
    tar gcc g++ ratfor              \
    gfortran libx11-dev make        \ 
    r-base libcurl4-openssl-dev     \ 
    locales openjdk-11-jdk          
RUN set -e \
    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x \
    export PATH=$JAVA_HOME/bin:$PATH

RUN javac -version    