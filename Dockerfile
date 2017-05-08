#use 16.04 lts, install certbot-auto to get newest certbot version
FROM ubuntu:16.04

#set default env variables
ENV DEBIAN_FRONTEND=noninteractive \
    CERTBOT_EMAIL="" \
    PROXY_ADDRESS="proxy" \
    CERTBOT_CRON_RENEW="('0 3 * * *' '0 15* * *')" \
    PATH="$PATH:/root"

# http://stackoverflow.com/questions/33548530/envsubst-command-getting-stuck-in-a-container
RUN apt-get update && \
    apt-get -y install cron supervisor curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install certbot-auto and docker-ce (use deb file, should be smaller compared to apt-get install docker-ce)
RUN curl -o /root/certbot-auto https://dl.eff.org/certbot-auto && \
    chmod a+x /root/certbot-auto && \
	/root/certbot-auto --version --non-interactive && \
	curl -o /root/docker-ce.deb https://download.docker.com/linux/ubuntu/dists/xenial/pool/stable/amd64/docker-ce_17.03.1~ce-0~ubuntu-xenial_amd64.deb && \
	dpkg -i /root/docker-ce.deb && \
	apt-get install -f && \
    apt-get purge -y --auto-remove gcc libc6-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# create letsencrypt folder for letsencrypt files (accounts, keys, certificates)
RUN mkdir /etc/letsencrypt

# Add supervisord.conf
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf 

# Add reqcert.py
ADD reqcert.py /reqcert.py

# Add certbot and make it executable
ADD certbot.sh /root/certbot.sh
RUN chmod u+x /root/certbot.sh

ADD renewAndSendToProxy.sh /root/renewAndSendToProxy.sh
RUN chmod u+x /root/renewAndSendToProxy.sh

RUN ln -sf /proc/1/fd/1 /var/log/dockeroutput.log

# Add symbolic link in cron.daily directory without ending (important!)
ADD renewcron /etc/cron.d/renewcron
RUN chmod u+x /etc/cron.d/renewcron

ADD servicestart /root/servicestart
RUN chmod u+x /root/servicestart

# Run the command on container startup
CMD ["/root/servicestart"]

EXPOSE 80
