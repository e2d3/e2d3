DOMAIN=localhost
mkdir -p ssl
openssl req -new -newkey rsa:2048 -nodes -subj "/CN=$DOMAIN" -keyout ssl/$DOMAIN.key -out ssl/$DOMAIN.csr
openssl x509 -req -days 3650 -in ssl/$DOMAIN.csr -signkey ssl/$DOMAIN.key -out ssl/$DOMAIN.crt
