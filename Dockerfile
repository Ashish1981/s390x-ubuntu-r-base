FROM docker.io/ibmjava

ENV R_BASE_VERSION 3.6.3
ENV SOURCE_ROOT /home/docker 
####
# Update the ubuntu image and load new s/w
####
RUN set -eux; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends ; \
    apt-get upgrade -y \
    apt-utils

RUN DEBIAN_FRONTEND="noninteractive" \
    apt-get -y install tzdata

RUN  set -eux; \
                \
    apt-get install -y wget         \
    tar gcc g++ ratfor              \
    gfortran libx11-dev make        \ 
    r-base libcurl4-openssl-dev     
    # locales openjdk-11-jdk          
RUN set -e \
    # export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x \
    export PATH=$JAVA_HOME/bin:$PATH 

RUN java -version    

# Set a default user. Available via runtime flag `--user docker`
# Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
# User should also have & own a home directory (for rstudio or linked volumes to work properly).
RUN useradd docker \
    && mkdir /home/docker \
    && chown docker:docker /home/docker \
    && addgroup docker staff

RUN cd $SOURCE_ROOT ;\
    wget https://cran.r-project.org/src/base/R-3/R-3.6.3.tar.gz ;\
    tar zxvf R-3.6.3.tar.gz; \
    mkdir -p $SOURCE_ROOT/build && cd $SOURCE_ROOT/build ; \
    $SOURCE_ROOT/R-3.6.3/configure --with-x=no --with-pcre1 ; \
    make ;  \
    make install 

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ed \
    less \
    locales \
    vim-tiny \
    wget \
    ca-certificates \
    fonts-texgyre \
    && rm -rf /var/lib/apt/lists/*

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.utf8 \
    && locale-gen en_GB.UTF-8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8

# RUN cd $SOURCE_ROOT/build \
#     apt-get install -y  \
#     texlive-latex-base  \
#     texlive-latex-extra  \
#     texlive-fonts-recommended \ 
#     texlive-fonts-extra 
    
# RUN cd $SOURCE_ROOT/build \
#     make check

RUN echo "sessionInfo()" | R --save

RUN apt-get update && apt-get install -y \
    supervisor \
    git-core \
    libsodium-dev \
    libssl-dev \
    libcurl4-gnutls-dev \
    xtail  \
    && R CMD javareconf 

# Download and install R modules
RUN install2.r  rJava

CMD [ "R" ]