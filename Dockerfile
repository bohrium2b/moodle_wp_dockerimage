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
    libsoap-ys-dev \
    libxmlrpc-epi-dev \
    unzip \
    wget \
    git \
    # Dependencies for Maxima and STACK
    maxima \
    maxima-share \
    sbcl \
    gnuplot \
    texlive \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-science \
    dvipng \
    && docker-php-ext-install \
    ctype \
    curl \
    dom \
    gd \
    iconv \
    intl \
    json \
    mbstring \
    pcre \
    simplexml \
    spl \
    xml \
    zip \
    openssl \
    soap \
    sodium \
    tokenizer \
    xmlrpc \
    && rm -rf /var/lib/apt/lists/*

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

# Download and Install Moodle at /elearn
ENV MOODLE_VERSION latest
ENV MOODLE_URL https://download.moodle.org/latest.zip

RUN mkdir -p /var/www/html/elearn \
    && wget -O /tmp/moodle.zip $MOODLE_URL \
    && unzip /tmp/moodle.zip -d /tmp \
    && rm /tmp/moodle.zip \
    && mv /tmp/moodle/* /var/www/html/elearn/ \
    && rm -rf /tmp/moodle

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

# Define volumes for persistence
VOLUME ["/var/www/html/wp-content/plugins", "/var/www/html/wp-content/themes"]
VOLUME ["/var/www/html/elearn/theme", "/var/www/html/elearn/mod", "/var/www/html/elearn/repository", "/var/www/html/elearn/local", "/var/www/html/elearn/blocks", "/var/www/html/elearn/data"]

EXPOSE 80
