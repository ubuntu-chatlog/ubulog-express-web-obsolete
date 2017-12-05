FROM node:8-alpine as builder
RUN apk update && apk add git
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN rm -f default.conf nginx.conf
RUN [ -e Dockerfile ] && rm -f Dockerfile
RUN [ -e docker-compose.yml ] && rm -f docker-compose.yml
RUN npm install -g bower && \
	npm install -g polymer-cli --unsafe-perm && \
	bower install --allow-root && \
	polymer build && \
	npm uninstall -g bower && \
	npm uninstall -g typescript

# FINAL image
FROM nginx:1.13-alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /usr/src/app /usr/share/nginx/html
RUN rm -f default.conf nginx.conf