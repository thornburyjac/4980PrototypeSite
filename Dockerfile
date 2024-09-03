FROM nginx
COPY index.html /usr/share/nginx/html
COPY base.html /usr/share/nginx/html
COPY cropped.html /usr/share/nginx/html
COPY obiwan.html /usr/share/nginx/html
