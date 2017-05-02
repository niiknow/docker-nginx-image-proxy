# https://www.scalescale.com/tips/nginx/nginx-proxy-cache-explained-2/
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=resizedimages:10m max_size=5g inactive=45m;

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    set $width -;
    set $height -;
    set $rotate 0;
    set $quality 75;
    set $sharpen 0;

    server_name                  _;
    root                        /usr/share/nginx/html;
    index                       index.html index.htm;

    resolver                    8.8.8.8 8.8.4.4;
 
    image_filter_buffer         20M;
    image_filter_interlace      on;

    proxy_cache_lock            on;
    proxy_cache_lock_timeout    120s;
    proxy_set_header            X-Resl-IP  $remote_addr;
    proxy_set_header            X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_hide_header           X-Cache;
    proxy_ignore_headers        Vary;
    proxy_ignore_headers        Expires;
    proxy_ignore_headers        Set-Cookie;
    proxy_ignore_headers        Cache-Control;

    proxy_pass_header           P3P;
    proxy_cache_min_uses        2;
    proxy_cache                 resizedimages;
    proxy_cache_valid           200 10m;

    location /healthcheck {
        default_type text/plain;
        return 200 "OK";
    }

    location ~* ^/rx/([^\/]+)/(http|https)+([:\/\/])+(.*) {
        set $myargs "$1";
        set $image_uri "$2://$4";
        set $cmd "resize";
        set $myfile "$4";
        set $myhost "$4";
        set $image_path "$4";

# image_filter_crop_offset {left,center,right} {top,center,bottom};
        set $crop_offx left;
        set $crop_offy top;
        
        if ($myhost !~ "___MY_WHITELIST_HOSTS___") {
            rewrite ^ /403 last;
            break;
        }

        if ($myfile ~ "^([^/]+)/(.*)") {
            set $myhost $1;
            set $image_path $2;
        }

# dimensions
        if ($myargs ~ "^\d+$") {
            set $width $myargs;
        }

        if ($myargs ~ "(\d+)x") {
            set $width $1;
        }

        if ($myargs ~ "x(\d+)") {
            set $height $1;
        }

# quality
        if ($myargs ~ "q([_]*)(\d+)") {
            set $quality $2;
        }

# rotate
        if ($myargs ~ "r([_]*)(\d+)") {
            set $rotate $2;
        }

# gravity
        if ($myargs ~ "g_Center") {
            set $crop_offx center;
            set $crop_offy center;
        }

        if ($myargs ~ "g_South") {
            set $crop_offy bottom;
        }

        if ($myargs ~ "g_(North|South)East") {
            set $crop_offx right;
        }

# sharpen
        if ($myargs ~ "e([_]*)(\d+)") {
            set $sharpen $2;
        }

# crop
        if ($myargs ~ c([_]*)1) {
            set $cmd "crop";
        }
        
        set $mycachekey "$image_uri?w=$width&h=$height&q=$quality&r=$rotate&e=$sharpen&cmd=$cmd";
        
        add_header  X-Image-Proxy  $mycachekey;
        rewrite ^ /cmd/$cmd last;
    }
    
    location /cmd/resize {
        internal;
        proxy_pass                 $image_uri;
        proxy_connect_timeout      60s;

        image_filter_sharpen       $sharpen;
        image_filter_jpeg_quality  $quality;
        image_filter               rotate  $rotate;
        image_filter               resize  $width $height;
        error_page                 415 = @empty;
    }
 
    location /cmd/crop {
        internal;
        proxy_pass                 $image_uri;
        proxy_connect_timeout      30s;
        
        image_filter_sharpen       $sharpen;
        image_filter_jpeg_quality  $quality;
        image_filter               rotate  $rotate;
        image_filter_crop_offset   $crop_offx $crop_offy;
        image_filter               crop  $width $height;
        error_page 415 = @empty;
    }

    location /403 {
        return 403;
    }

    location @empty {
        empty_gif;
    }
}


