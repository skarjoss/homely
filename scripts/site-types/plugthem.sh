#!/usr/bin/env bash

declare -A params=$6       # Create an associative array
declare -A headers=${9}    # Create an associative array
declare -A rewrites=${10}  # Create an associative array
paramsTXT=""
if [ -n "$6" ]; then
   for element in "${!params[@]}"
   do
      paramsTXT="${paramsTXT}
      fastcgi_param ${element} ${params[$element]};"
   done
fi
headersTXT=""
if [ -n "${9}" ]; then
   for element in "${!headers[@]}"
   do
      headersTXT="${headersTXT}
      add_header ${element} ${headers[$element]};"
   done
fi
rewritesTXT=""
if [ -n "${10}" ]; then
   for element in "${!rewrites[@]}"
   do
      rewritesTXT="${rewritesTXT}
      location ~ ${element} { if (!-f \$request_filename) { return 301 ${rewrites[$element]}; } }"
   done
fi

if [ "$7" = "true" ]
then configureXhgui="
location /xhgui {
        try_files \$uri \$uri/ /xhgui/index.php?\$args;
}
"
else configureXhgui=""
fi

if [ -n "${12}" ] && [ -n "${13}" ]
then 
    if ! [[ "${13}" =~ ^[0-9]+$ ]]
    then
        proxyPass1="
        proxy_pass ${13};
        "
    else proxyPass1="
        proxy_pass http://127.0.0.1:${13};
        "
    fi
    configurePath1="
        location /${12}/ {
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header Upgrade \$http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_set_header Host \$host;
                proxy_http_version 1.1;
                $proxyPass1
                $headersTXT
                $paramsTXT
            }
        "
else configurePath1=""
fi

case "$1" in 
  *voc* | *cx* | *test*)
        configureVocNSmartLink="
    location ~ ^/nsmartlink/(.*)$ {
        # kill cache
        add_header Last-Modified \$date_gmt;
        add_header Cache-Control 'no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0';
        if_modified_since off;
        expires off;
        etag off;
        proxy_no_cache 1; # don't cache it
        proxy_cache_bypass 1; # even if cached, don't try to use it
        
        root \"$2\";
        try_files \$uri \$uri/ /nsmartlink/index.html;
    }
    
    location ~ ^/surveysmanagement/(.*)$ {
        # kill cache
        add_header Last-Modified \$date_gmt;
        add_header Cache-Control 'no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0';
        if_modified_since off;
        expires off;
        etag off;
        proxy_no_cache 1; # don't cache it
        proxy_cache_bypass 1; # even if cached, don't try to use it
        
        root \"$2\";
        try_files \$uri \$uri/ /surveysmanagement/index.html;
    }
    
    location ~ ^/smartlink/(.*)$ {
        # kill cache
        add_header Last-Modified \$date_gmt;
        add_header Cache-Control 'no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0';
        if_modified_since off;
        expires off;
        etag off;
        proxy_no_cache 1; # don't cache it
        proxy_cache_bypass 1; # even if cached, don't try to use it
        
        root \"$2\";
        try_files \$uri \$uri/ /smartlink/index.html;
    }
    "
    ;;
  *)
    configureVocNSmartLink=""
    ;;
esac

if [[ $1 == *"bpm3"* ]]; then
    cgiIndex="app.php"
    cgiScriptFilename="/app.php"
else
    cgiIndex="index.php"
    cgiScriptFilename="\$fastcgi_script_name"
fi

block="server {
    listen ${3:-80};
    listen ${4:-443} ssl http2;
    server_name .$1;
    root \"$2\";
    
    #add_header Access-Control-Allow-Origin *;

    index index.html index.htm index.php app.php;

    charset utf-8;
    client_max_body_size 100M;

    $rewritesTXT

    location / {
        try_files \$uri \$uri/ /$cgiIndex?\$query_string;
        $headersTXT
    }

    $configureXhgui
    
    $configurePath1

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/$1-error.log error;

    sendfile off;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php$5-fpm.sock;
        fastcgi_index $cgiIndex;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root$cgiScriptFilename;
        $paramsTXT

        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
    
    $configureVocNSmartLink

    ssl_certificate     /etc/ssl/certs/$1.crt;
    ssl_certificate_key /etc/ssl/certs/$1.key;
}
"

echo "$block" > "/etc/nginx/sites-available/$1"
ln -fs "/etc/nginx/sites-available/$1" "/etc/nginx/sites-enabled/$1"
