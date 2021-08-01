FROM klakegg/hugo:ext-alpine as build

COPY ./ /site
WORKDIR /site
RUN ls -lah
RUN hugo

#Copy static files to Nginx
FROM nginx:alpine
COPY --from=build /site/public /usr/share/nginx/html

WORKDIR /usr/share/nginx/html