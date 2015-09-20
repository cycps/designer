FROM ubuntu:15.04
RUN apt-get update && apt-get install -y \
  vim \
  tmux \
  nginx \
  rsync \
  ssh 

RUN mkdir -p /cypress/web
RUN mkdir -p /cypress/web/ico
COPY . /cypress/web/
COPY conf/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /root/.ssh
COPY /devkeys/ssh/* /root/.ssh/
RUN cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys

EXPOSE 443

CMD service ssh start && nginx
