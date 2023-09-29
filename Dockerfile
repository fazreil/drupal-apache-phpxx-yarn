FROM php:8.1-apache

# added node 16 from nodesource
#RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -

RUN apt-get update
RUN apt-get install -y ca-certificates curl gnupg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

RUN apt-get update

# install dependency library
RUN apt-get update && apt-get install -y \
      git \
      curl \
      imagemagick \
      libfreetype6-dev \
      libjpeg-dev \
      libpng-dev \
      libpq-dev \
      libmagickwand-dev \
      libonig-dev \
      libxml2-dev \
      libzip-dev \
      zip \
      unzip \
      nodejs \
      && apt-get clean \
      && rm -r /var/lib/apt/lists/*

# install yarn
# RUN npm install --global yarn

RUN a2enmod rewrite && \
      a2enmod headers

# install additional php extension redis from pecl
RUN pecl install -o -f redis \
      &&  rm -rf /tmp/pear \
      &&  docker-php-ext-enable redis

# install apcu ext
RUN pecl install apcu \
      &&  rm -rf /tmp/pear \
      &&  docker-php-ext-enable apcu

# install imagick php extension for pdf thumbnail
RUN pecl install imagick \
      && docker-php-ext-enable imagick

# fix image PDF policy
RUN sed -i 's/<policy domain="coder" rights="none" pattern="PDF" \/>/<policy domain="coder" rights="read|write" pattern="PDF" \/>/g' /etc/ImageMagick-6/policy.xml

# Install PHP extensions
RUN docker-php-ext-configure gd \
      --with-freetype \
      --with-jpeg

RUN docker-php-ext-install \
      pdo_mysql \
      mbstring \
      exif \
      pcntl \
      bcmath \
      gd \
      zip \
      opcache

# Get latest Composer
COPY --from=composer:2.1.12 /usr/bin/composer /usr/bin/composer
RUN chmod +x /usr/bin/composer

# install drush
RUN curl -L --silent https://github.com/drush-ops/drush/releases/download/8.4.8/drush.phar \
  > /usr/local/bin/drush && chmod +x /usr/local/bin/drush

# Set working directory
WORKDIR /var/www/html

ENV PATH=${PATH}:/opt/drupal/vendor/bin

#ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

