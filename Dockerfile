FROM centos:7

# PHPの設定
ENV PHP_VERSION "7.4.33"
ENV PHP_CONFIGURE \
    "--enable-maintainer-zts" \
    "--with-pdo-mysql" \
    "--enable--mbstring" \
    "--with-openssl" \
    "--enable-gd"

# Swooleの設定
ENV SWOOLE_VERSION "v4.7.1"
ENV SWOOLE_TYPE "swoole"

# parallelの設定
ENV ENABLE_PARALLEL "0"
ENV PARALLEL_VERSION "v1.1.4"

ENV PHP_INI_PATH "/usr/local/lib/php.ini"

WORKDIR tmp

# centos7のサポートが終了しているため、リポジトリを変更
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
        sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

RUN yum update -y && \
    yum install -y epel-release

# 必要な処理をインストール \
RUN yum install -y \
    git \
    wget \
    openssl-devel \
    pkg-config \
    autoconf \
    libtool \
    make \
    ccache \
    bison \
    re2c \
    libxml2-devel \
    sqlite-devel \
    zlib1g-devel \
    libpng-devel \
    oniguruma-devel

# PHPをビルドしてインストール
RUN git clone https://github.com/php/php-src.git

RUN yum install -y gcc-c++

WORKDIR php-src
RUN git checkout php-$PHP_VERSION && \
    sed -i.bak -e '503,507c\\#define ZEND_USE_ASM_ARITHMETIC 0' Zend/zend_operators.h && \
    ./buildconf --force && \
    ./configure $PHP_CONFIGURE && \
    make -j$(nproc) && \
    make install

# Swooleをインストール
WORKDIR tmp
RUN git clone https://github.com/$SWOOLE_TYPE/swoole-src.git && \
    cd swoole-src && \
    git checkout $SWOOLE_VERSION && \
    phpize && \
    ./configure --enable-openssl && \
    make install

# peclをインストール
WORKDIR php-src
RUN wget http://pear.php.net/go-pear.phar && \
    php ./go-pear.phar

RUN pecl install inotify && \
    pecl install redis

# inotifyとredisを有効化
RUN echo "extension=inotify.so" >> $PHP_INI_PATH && \
    echo "extension=redis.so" >> $PHP_INI_PATH

# parallelのインストールが有効な場合
RUN if [ "$ENABLE_PARALLEL" = "1" ]; then \
    git clone https://github.com/krakjoe/parallel.git && \
    cd parallel && \
    git checkout $PARALLEL_VERSION && \
    phpize && \
    ./configure && \
    make -j&(nproc) && \
    make install && \
    echo "extension=parallel.so" >> $PHP_INI_PATH \
    ; \
    fi

CMD php -a
