FROM debian:stretch-slim

MAINTAINER Irek Pelech

ENV TERM=xterm-256color

COPY ssh-user-auth.sh /usr/bin/ssh-user-auth.sh
COPY entrypoint.sh /usr/bin/entrypoint.sh

RUN apt-get -q update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		openssh-server netcat telnet curl \
	&& mkdir /var/run/sshd \
	&& echo "AuthorizedKeysCommand /usr/bin/ssh-user-auth.sh" >> /etc/ssh/sshd_config \
  	&& echo "AuthorizedKeysCommandUser nobody" >> /etc/ssh/sshd_config \
	&& apt-get clean autoclean \
  	&& apt-get autoremove --yes \
  	&& rm -rf /var/lib/{apt,dpkg,cache,log}/ \
	&& chmod 755 /usr/bin/ssh-user-auth.sh \
	&& chmod 755 /usr/bin/entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
