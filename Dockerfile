FROM inclusivedesign/php:5.4

ADD data/ /var/www/
ADD start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh && \
    yum -y install ImageMagick php5-curl

VOLUME ["/var/www/wp-content"]

EXPOSE 80

CMD ["/usr/local/bin/start.sh"]
