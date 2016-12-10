FROM silintl/php7
MAINTAINER Your Name <your_email@domain.com>

ENV REFRESHED_AT 2015-05-11

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Run updates and install deps
RUN apt-get update

RUN apt-get install -y -q --no-install-recommends \
    apt-transport-https \
    build-essential \
    ca-certificates \
    curl \
    g++ \
    gcc \
    git \
    make \
    nginx \
    sudo \
    wget \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get -y autoclean

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 7.0.0

# Install nvm with node and npm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash \
    && source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# Set up our PATH correctly so we don't have to long-reference npm, node, &c.
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y supervisor curl && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Install symfony installer
RUN curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony
RUN chmod a+x /usr/local/bin/symfony

# Install PHP Code Sniffer
RUN apt-get install wget
RUN wget http://pear.php.net/go-pear.phar
RUN php go-pear.phar
RUN pear install PHP_CodeSniffer

ADD run.sh /run.sh
ADD start-apache2.sh /start-apache2.sh
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf

# Copy an Apache vhost file into sites-enabled. This should map
# the document root to whatever is right for your app
COPY vhost-config.conf /etc/apache2/sites-enabled/

RUN mkdir -p /data
VOLUME ["/data"]

# setup GIT & codesniffer
RUN git clone https://github.com/Usertech/php-coding-standards.git /usr/share/pear/PHP/CodeSniffer/Standards/Usertech
RUN cd /usr/share/pear/PHP/CodeSniffer/Standards/Usertech && composer install

# add ssh-key
# ADD _config/id_rsa /root/.ssh/id_rsa 
# ADD _config/id_rsa.pub /root/.ssh/id_rsa.pub 
# RUN chmod 500 /root/.ssh/id_rsa*

WORKDIR /data
EXPOSE 80 8000
# CMD ["apache2ctl", "-D", "FOREGROUND"]
CMD ["/run.sh"]