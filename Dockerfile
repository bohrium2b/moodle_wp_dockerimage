FROM php:8.3-apache

# Install required PHP extensions and system dependencies
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libzip-dev \
    libxml2-dev \
    libicu-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libsodium-dev \
    libonig-dev \
    libxslt1-dev \
    libmagickwand-dev \
    libexif-dev \
    libxmlrpc-epi-dev \
    unzip \
    wget \
    git \
    # Dependencies for Maxima and STACK
    sbcl \
    gnuplot \
    texlive \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-science \
    dvipng 

# Install build tools and ensure dependencies for PHP extensions are installed
RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    libtool \
    pkg-config \
    && apt-get clean


RUN docker-php-source extract

# Ensure the required PHP extension source code is available
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp

RUN docker-php-ext-install ctype
RUN docker-php-ext-install curl
RUN docker-php-ext-install dom
RUN docker-php-ext-install gd
RUN docker-php-ext-install iconv
RUN docker-php-ext-install intl
RUN docker-php-ext-install xml
RUN docker-php-ext-install zip
RUN docker-php-ext-install soap
RUN docker-php-ext-install sodium
RUN docker-php-ext-install mysqli
RUN rm -rf /var/lib/apt/lists/*

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set up document root for Wordpress at /
ENV WORDPRESS_VERSION latest
ENV WORDPRESS_URL https://wordpress.org/latest.zip

RUN wget -O /tmp/wordpress.zip $WORDPRESS_URL \
    && unzip /tmp/wordpress.zip -d /tmp \
    && rm /tmp/wordpress.zip \
    && mv /tmp/wordpress/* /var/www/html/ \
    && rm -rf /tmp/wordpress


RUN mkdir -p /var/www/html/elearn \
    && cd /tmp \
    && git clone -b MOODLE_500_STABLE https://github.com/moodle/moodle.git moodle \
    && mv /tmp/moodle/* /var/www/html/elearn/ \
    && rm -rf /tmp/moodle
# Set Moodle data directory
RUN mkdir -p /var/www/moodledata \
    && chown -R www-data:www-data /var/www/moodledata \
    && chmod -R 770 /var/www/moodledata
# Note: You may want to change the Moodle data directory path as needed



# Set correct permissions
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

# Configure Apache to serve Moodle at /elearn and Wordpress at /
RUN echo '<Directory /var/www/html/elearn>\nAllowOverride All\nRequire all granted\n</Directory>' >> /etc/apache2/apache2.conf

# Custom Apache config for URL routing
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html\n\
    Alias /elearn /var/www/html/elearn\n\
    <Directory /var/www/html>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    <Directory /var/www/html/elearn>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Build Maxima
# Build Maxima from source for SBCL
ENV MAXIMA_VERSION=5.47.0
RUN cd /tmp \
    && wget https://sourceforge.net/projects/maxima/files/Maxima-source/${MAXIMA_VERSION}/maxima-${MAXIMA_VERSION}.tar.gz \
    && tar xvf maxima-${MAXIMA_VERSION}.tar.gz \
    && cd maxima-${MAXIMA_VERSION} \
    && ./configure --with-sbcl --prefix=/usr \
    && make \
    && make install \
    && cd / && rm -rf /tmp/maxima-${MAXIMA_VERSION} /tmp/maxima-${MAXIMA_VERSION}.tar.gz

# Define volumes for persistence
VOLUME ["/var/www/html/wp-content/plugins", "/var/www/html/wp-content/themes"]
VOLUME ["/var/www/html/elearn/theme", "/var/www/html/elearn/mod", "/var/www/html/elearn/repository", "/var/www/html/elearn/local", "/var/www/html/elearn/blocks", "/var/www/html/elearn/data"]

EXPOSE 80
