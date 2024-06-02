server {
    if ($host = matrix.privateship.xyz) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    server_name privateship.xyz;

    # Redirect HTTP to HTTPS for Jellyfin
    listen 80;
    listen [::]:80;
    return 301 https://$host$request_uri;


}

server {
    server_name matrix.privateship.xyz;

    # SSL configuration for Matrix Dendrite
    listen [::]:443 ssl http2; # managed by Certbot
    listen 443 ssl http2; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/matrix.privateship.xyz/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/matrix.privateship.xyz/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    # Set client max body size to 1G
    client_max_body_size 500M;

    location /_matrix {
        proxy_pass http://matrix.privateship.xyz:8008;  # Assuming Matrix Dendrite container name is "matrix_dendrite"
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /.well-known/matrix/server {
        return 200 '{ "m.server": "matrix.privateship.xyz:443" }';
    }

    location /.well-known/matrix/client {
        return 200 '{ "m.homeserver": { "base_url": "https://matrix.privateship.xyz" } }';
    }

}

server {
    server_name privateship.xyz;

    # SSL configuration for Jellyfin
    listen [::]:443 ssl http2; # managed by Certbot
    listen 443 ssl http2; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/privateship.xyz-0001/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/privateship.xyz-0001/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    location / {
        proxy_pass http://0.0.0.0:8096;  # Assuming Jellyfin container name is "jellyfin"
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }


}

