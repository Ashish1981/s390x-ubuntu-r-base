FROM docker.io/s390x/ubuntu:20.04

ENV R_BASE_VERSION 3.6.3
ENV SOURCE_ROOT /home/shiny 
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
    r-base libcurl4-openssl-dev     \
    locales openjdk-11-jdk          

RUN set -e \
    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x \
    export PATH=$JAVA_HOME/bin:$PATH 

RUN java -version && \
    javac -version

RUN apt-get update \
    && apt-get install -y  \
    sudo \
    bash-completion \
    ca-certificates \
    file \
    fonts-texgyre \
    g++ \
    gfortran \
    gsfonts \
    libblas-dev \
    libbz2-1.0 \
    libcurl4 \
    # libicu63 \
    # libjpeg62-turbo \
    libopenblas-dev \
    libpangocairo-1.0-0 \
    libpcre3 \
    libpng16-16 \
    libreadline7 \
    libtiff5 \
    liblzma5 \
    locales \
    make \
    unzip \
    zip \
    zlib1g \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.utf8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8 \
    && BUILDDEPS="curl \
    default-jdk \
    default-jre \
    libbz2-dev \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libicu-dev \
    libpcre3-dev \
    libpng-dev \
    libreadline-dev \
    libtiff5-dev \
    liblzma-dev \
    libx11-dev \
    libxt-dev \
    perl \
    tcl8.6-dev \
    tk8.6-dev \
    texinfo \
    texlive-extra-utils \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-latex-recommended \
    x11proto-core-dev \
    xauth \
    xfonts-base \
    xvfb \
    zlib1g-dev" \
    && apt-get install -y  $BUILDDEPS

RUN apt-get update && apt-get install -y \
    supervisor \
    git-core \
    libsodium-dev \
    libssl-dev \
    libcurl4-gnutls-dev \
    xtail  

RUN apt-get update && apt-get install -y \
    liblzma-dev \
    libbz2-dev \
    clang  \
    ccache     

# Set a default user. Available via runtime flag `--user shiny`
# Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
# User should also have & own a home directory (for rstudio or linked volumes to work properly).
RUN useradd shiny \
    && mkdir /home/shiny \
    && chown shiny:shiny /home/shiny \
    && addgroup shiny staff

RUN cd $SOURCE_ROOT ;\
    wget https://cran.r-project.org/src/base/R-3/R-3.6.3.tar.gz ;\
    tar zxvf R-3.6.3.tar.gz; \
    mkdir -p $SOURCE_ROOT/build && cd $SOURCE_ROOT/build ; \
    # $SOURCE_ROOT/R-3.6.3/configure --with-x=no --with-pcre1 ; \
    $SOURCE_ROOT/R-3.6.3/configure ; \
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

RUN cd $SOURCE_ROOT/build \
    apt-get install -y  \
    texlive-latex-base  \
    texlive-latex-extra  \
    texlive-fonts-recommended \ 
    texlive-fonts-extra 
    
RUN cd $SOURCE_ROOT/build \
    make check
 


RUN export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x \
    && export PATH=$JAVA_HOME/bin/:$PATH \
    && setarch s390x R CMD javareconf \ 
    && echo "sessionInfo()" | R --save 
RUN Rscript -e "update.packages(checkBuilt=TRUE, ask=FALSE, repos='https://cloud.r-project.org')"
RUN Rscript -e "install.packages(c('devtools'), dependencies = TRUE, repo = 'https://cloud.r-project.org')"    
RUN Rscript -e "install.packages(c('littler'), dependencies = TRUE, repo = 'https://cloud.r-project.org')"    
