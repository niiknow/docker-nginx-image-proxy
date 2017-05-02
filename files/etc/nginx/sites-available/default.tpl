# https://www.scalescale.com/tips/nginx/nginx-proxy-cache-explained-2/
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_diskcached:10m max_size=5g inactive=45m;

server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    resolver 8.8.8.8;

    image_filter_buffer     20M;
    image_filter_interlace  on;

    proxy_cache_lock            on;
    proxy_cache_lock_timeout    60s;
    proxy_set_header            X-Forwarded-For $remote_addr;
    proxy_hide_header           X-Cache;
    proxy_ignore_headers        Vary;
    proxy_ignore_headers        Expires;
    proxy_ignore_headers        Set-Cookie;
    proxy_ignore_headers        Cache-Control;

    proxy_pass_header           P3P;
    proxy_cache_min_uses        2;
    proxy_cache                 my_diskcached;
    proxy_cache_valid           200 10m;

    location ~ ^/rx/([^\/]+)/(http|https)+([:\/\/])+(.*) {
        set $myargs "$1";
        set $image_uri "$2://$4$5";
        set $myhost $4;
        set $width -;
        set $height -;
        set $rotate 0;
        set $quality 90;

        if ($myhost ~ "([^/]+)") {
            set $myhost $1;
        }

        if ($myhost !~ "___MY_WHITELIST_HOSTS___") {
            rewrite ^ /403 last;
        }

# image_filter_crop_offset {left,center,right} {top,center,bottom};
        set $crop_offx left;
        set $crop_offy top;

        if ($myargs ~ "^\d+$") {
            set $width $myargs;
        }

        if ($myargs ~ "(\d+)x") {
            set $width $1;
        }

        if ($myargs ~ "x(\d+)") {
            set $height $1;
        }

        if ($myargs ~ "q_(100|[1-9][0-9]|[1-9])") {
            set $quality $1;
        }

        if ($myargs ~ "rz_\d+") {
            set $rotate $1;
        }

# set gravity
        if ($myargs ~ "g_Center") {
            set $crop_offx center;
            set $crop_offy center;
        }

        if ($myargs ~ "g_South") {
            set $crop_offy bottom;
        }

        if ($myargs ~ "g_(.+)East") {
            set $crop_offx right;
        }

        if ($myargs ~ "\d+x\d+") {
            rewrite ^ /crop last;
            break;
        }

        if ($myargs ~ c_1) {
            rewrite ^ /crop last;
            break;
        }


        proxy_pass                 $image_uri;
        image_filter_jpeg_quality  $quality;
        image_filter               rotate  $rotate;
        image_filter               resize  $width $height;

        # error_page 415 = @empty;
    }

    location /crop {
        internal;

        proxy_pass                 $image_uri;

        image_filter_jpeg_quality  $quality;
        image_filter               rotate  $rotate;
        image_filter_crop_offset   $crop_offx $crop_offy;
        image_filter               crop  $width $height;


        # error_page 415 = @empty;
    }

    location /403 {
        return 403;
    }

    location @empty {
        empty_gif;
    }
}


