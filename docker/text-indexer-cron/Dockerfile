FROM openjdk:11

RUN apt update && apt install -y cron openjdk-11-jdk

# Setup cron
COPY ./index-cron /etc/cron.d/index-cron
RUN chmod 0644 /etc/cron.d/index-cron
RUN crontab /etc/cron.d/index-cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

COPY ./startup.sh /usr/local/text-indexer-cron/startup.sh
RUN chmod u+x /usr/local/text-indexer-cron/startup.sh

CMD /usr/local/text-indexer-cron/startup.sh
