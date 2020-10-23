# Base image
FROM s390x/ubuntu:20.04 AS builder

# The author
LABEL maintainer="LoZ Open Source Ecosystem (https://www.ibm.com/developerworks/community/groups/community/lozopensource)"

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x
ENV R_BASE_VERSION 4.0.2
ENV SOURCE_DIR=/tmp/source

WORKDIR $SOURCE_DIR

# Install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    g++ \
    gcc \
    gfortran \
    libcurl4-openssl-dev \
    libx11-dev \
    locales \
    make \
    openjdk-11-jdk \
    r-base \
    ratfor \
    tar \
    wget

# Download and build R
RUN wget https://cran.r-project.org/src/base/R-4/R-${R_BASE_VERSION}.tar.gz \
    && tar zxvf R-${R_BASE_VERSION}.tar.gz && cd R-${R_BASE_VERSION} \
    && ./configure --with-x=no --with-pcre1 && make && make install \
    && locale-gen "en_US.UTF-8" \
    && locale-gen "en_GB.UTF-8"

# Clean up cache data and remove dependencies that are not required
RUN apt-get remove -y \
    g++ \
    gcc \
    gfortran \
    libcurl4-openssl-dev \
    libx11-dev \
    locales \
    make \
    openjdk-11-jdk \
    ratfor \
    wget \
    && apt-get autoremove -y \
    && apt autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* $SOURCE_DIR/R-${R_BASE_VERSION}.tar.gz 

# Multistage build
FROM s390x/ubuntu:20.04
RUN apt-get update && apt-get install -y libreadline8
WORKDIR /root
COPY --from=builder /usr/local/bin/R /usr/local/bin/R
COPY --from=builder /usr/local/bin/Rscript /usr/local/bin/Rscript
COPY --from=builder /usr/lib/ /usr/lib/
COPY --from=builder /usr/local/lib/ /usr/local/lib/


CMD ["R"]
# End of Dockerfile