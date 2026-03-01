FROM nginx:alpine3.23 as build

# Copy custom nginx config (handles /ws proxying to ws-server)
COPY files/nginx.conf /etc/nginx/conf.d/default.conf

# Copy and prepare the HTML template
COPY files/index.html.tftpl /etc/nginx/templates/index.html.template

ENV NGINX_ENVSUBST_OUTPUT_DIR=/usr/share/nginx/html

EXPOSE 80
