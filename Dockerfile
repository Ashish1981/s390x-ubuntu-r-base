FROM docker.io/s390x/ubuntu:20.04

ENV R_BASE_VERSION 4.0.2
ENV SOURCE_ROOT /home/shiny 
ENV CRAN=${CRAN:-https://cloud.r-project.org} \ 
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    TERM=xterm
####
# Update the ubuntu image and load new s/w
####
RUN set -eux; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    # apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-get install -y --no-install-recommends ; \
    apt-get upgrade -y 
    # apt-get install -y apt-utils
# Need this to add R repo
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common
# Install basic stuff and R
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    sudo \
    git \
    vim-tiny \
    less \
    wget \
    r-base \
    r-base-dev \
    r-recommended \
    fonts-texgyre

## https://github.com/rstudio/shiny-server/blob/master/docker/ubuntu16.04/Dockerfile
RUN echo 'options(\n\
    repos = c(CRAN = "https://cloud.r-project.org/"),\n\
    download.file.method = "libcurl",\n\
    # Detect number of physical cores\n\
    Ncpus = parallel::detectCores(logical=FALSE)\n\
    )' >> /etc/R/Rprofile.site



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

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    # && DEBIAN_FRONTEND=noninteractive apt-get install -y  \
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
    libopenblas-dev \
    libpangocairo-1.0-0 \
    libpcre3 \
    libpng16-16 \
    ####libreadline7 \ (removed for ubuntu 20.04)
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

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    supervisor \
    git-core \
    libsodium-dev \
    libssl-dev \
    libcurl4-gnutls-dev \
    xtail  

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    liblzma-dev \
    libbz2-dev \
    clang  \
    ccache \
    libxml2-dev

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

# Set a default user. Available via runtime flag `--user shiny`
# Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
# User should also have & own a home directory (for rstudio or linked volumes to work properly).

# RUN useradd shiny \
#     && mkdir /home/shiny \
#     && chown shiny:shiny /home/shiny \
#     && addgroup shiny staff

# Create shiny user with empty password (will have uid and gid 1000)
RUN useradd --create-home --shell /bin/bash shiny \
    && passwd shiny -d \
    && adduser shiny sudo

# Don't require a password for sudo
RUN sed -i 's/^\(%sudo.*\)ALL$/\1NOPASSWD:ALL/' /etc/sudoers

# COPY /scripts/build-r.sh /home/shiny/

# RUN chmod + /home/shiny/build-r.sh ; /bin/bash /home/shiny/build-r.sh -y -j large


# RUN cd $SOURCE_ROOT ;\
#     wget https://cran.r-project.org/src/base/R-3/R-3.6.3.tar.gz ;\
#     tar zxvf R-3.6.3.tar.gz; \
#     mkdir -p $SOURCE_ROOT/build && cd $SOURCE_ROOT/build ; \
#     # $SOURCE_ROOT/R-3.6.3/configure --with-x=no --with-pcre1 ; \
#     $SOURCE_ROOT/R-3.6.3/configure --with-x=no --with-pcre1; \
#     make ;  \
#     # make install \
#     make prefix=$SOURCE_ROOT install-libR 

# Download and build R
RUN cd $SOURCE_ROOT ;\
    wget https://cran.r-project.org/src/base/R-4/R-${R_BASE_VERSION}.tar.gz \
    && tar zxvf R-${R_BASE_VERSION}.tar.gz && cd R-${R_BASE_VERSION} \
    && ./configure --with-x=no --with-pcre1 && make  \
    # && make install \
    && make prefix=$SOURCE_ROOT install-libR \
    && locale-gen "en_US.UTF-8" \
    && locale-gen "en_GB.UTF-8"

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
    
RUN cd $SOURCE_ROOT/build \
    make check
  

RUN export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-s390x \
    && export PATH=$JAVA_HOME/bin/:$PATH \
    && setarch s390x R CMD javareconf \ 
    && echo "sessionInfo()" | R --save 



# RUN R -e "update.packages(checkBuilt=TRUE, ask=FALSE, repos='https://cloud.r-project.org')"
# # RUN R -e "install.packages(c('devtools'), dependencies = TRUE, repo = 'https://cloud.r-project.org')"    
# # RUN R -e "install.packages(c('littler'), dependencies = TRUE, repo = 'https://cloud.r-project.org')"    
# # RUN R -e "install.packages('devtools', repos = 'http://cran.us.r-project.org')"
# # RUN R -e "install.packages('littler', repos = 'http://cran.us.r-project.org')"
# # RUN R -e "install.packages('devtools', repos = 'https://cloud.r-project.org')"
# # RUN R -e "install.packages('littler', repos = 'https://cloud.r-project.org')"
# RUN R -e "install.packages(c('devtools'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('class'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('zoo'), dependencies = TRUE, repo = '$CRAN')"
# # 
# RUN R -e "install.packages(c('lattice'), dependencies = TRUE, repo = '$CRAN')"
# # 
# RUN R -e "install.packages(c('littler'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('hexbin'), dependencies = TRUE, repo = '$CRAN')"
# # 
# RUN R -e "install.packages(c('rJava'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('RJDBC'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('shiny'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('shinydashboard'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('curl'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('httr'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('jsonlite'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('DT'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('shinyalert'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('stringr'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('dplyr'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('plotly'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('rmarkdown'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('leaflet'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('htmlwidgets'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('data.table'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('shinyjs'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('DBI'), dependencies = TRUE, repo = '$CRAN')"
# #
# RUN R -e "install.packages(c('plumber'), dependencies = TRUE, repo = '$CRAN')"
# #