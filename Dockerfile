FROM ubuntu:15.04
RUN apt-get update && apt-get install -y \
  vim \
  tmux \
  nginx

RUN mkdir -p /cypress/web
COPY . /cypress/web/
COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD nginx
