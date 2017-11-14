# nginx image proxy
>High Performance and Low Resource Utilization Microservice

image cropping with gravity, resize and compress on the fly with nginx **image_filter** module.  A tiny docker container to build your own Cloudinary-like service.

Nginx module - https://github.com/niiknow/docker-nginx-image-proxy/blob/master/build/src/ngx_http_image_filter_module.c

Features:
- [x] image crop offset, credit: https://github.com/bobrik/nginx_image_filter
- [x] /healthcheck endpoint
- [x] empty gif on other errors: 403, 404, 415, 500, 502, 503, 504
- [x] convert/force output to another format, support formats: bmp, jpg, png, gif, webp, and tiff 
- [x] use custom ssl and saved config when you mount '/app' volume.  nginx logs has also been redirect so you can backup, such as aws s3 sync.  Just delete the default redirect to stdout/access.log and stderr/error.log files.
- [x] support international characters in URL
- [x] automatically follow redirect at origin 
- [x] overridable nginx config - easily add secure link or additional nginx config

# What does this solve?
You have a huge repository of images that need dynamic resize and cropping.  Cloudinary can be expensive and redundant if you run your own CDN in front of this microservice.

# And what it doesn't?
Unlike other libraries, this does not try to do every image transformation and/or caching.

1.  For more advanced features such as: animated gif, face detection, auto image optimization, and others; we recommend using Cloudinary or similar service.
2.  Outside of disk cache, there is no plan for other Caching methods.  We recommend putting a CDN in front, such as (MaxCDN/StackPath/KeyCDN), to provide caching and easy SSL.  We love StackPath/MaxCDN EdgeRules™.
3.  If you want thumbnail caching to s3, just write a lambda function and use this server to generate your thumbnail.  Upload the result to s3 with the same function.

# build
To achieve smaller/tiny microservice, this container utilize multi-stage build introduced in Docker 17.06; therefore, Docker 17.06+ is required to build.

```
docker build -t nginx-image-proxy .
```

# run
docker run -d --restart=always -p 80:80 niiknow/nginx-image-proxy
--env SERVER_CONF='https://gist.githubusercontent.com/...'

# web
Example: http://imageproxy.yourdomain.com/rx/url-options/http://remote-host.com/image-path/image.jpg

or http as protocol default: http://imageproxy.yourdomain.com/rx/url-options/remote-host.com/image-path/image.jpg

Option Keys:
-------------

```yml
code: name - valid values - default
  q: quality - 1..100 - 96 (default to best in case it's previously optimized) 
  w: width - uint - null
  h: height - uint - null
  c: crop - null, 1 - null
  rz: resize - null, 1 - 1
  g: gravity - NorthWest, North, NorthEast, West, Center, East, SouthWest, South, SouthEast *case-sensitive* - NorthWest
  e: sharpen - 1..100 - 0
  r: rotate - 0, 90, 180, 270 - 0
  ofmt: bmp, jpg, jpeg, png, gif, webp - force output format
```

Options Usages:
----------------

Options are a subset of Cloudinary. It's also very flexible and customizable.

* Like Cloudinary with underscore (_) as separator:  OptionKey_OptionValue - g_Center, w_100, h_100
* Or without any separator: OptionKeyOptionValue - gCenter, w100, h100
* Or in a QueryString: ?g=Center&w=100&h=100

And if that doesn't work, you can always use your custom nginx config by passing the config url into docker environment variable: SERVER_CONF

# Example 
* Original Image - https://octodex.github.com/images/codercat.jpg - 896x896
* Dynamic Height - http://imageproxy.niiknow.org/rx/50/https://octodex.github.com/images/codercat.jpg
![Dynamic Height](http://imageproxy.niiknow.org/rx/50/https://octodex.github.com/images/codercat.jpg)

* Dynamic Width - http://imageproxy.niiknow.org/rx/x100/https://octodex.github.com/images/codercat.jpg
![Dynamic Width](http://imageproxy.niiknow.org/rx/x100/https://octodex.github.com/images/codercat.jpg)

* Fix Width and Height, fit - http://imageproxy.niiknow.org/rx/200x500/https://static.pexels.com/photos/104827/cat-pet-animal-domestic-104827.jpeg
![Fix Width and Height - fit](http://imageproxy.niiknow.org/rx/200x500/https://static.pexels.com/photos/104827/cat-pet-animal-domestic-104827.jpeg)

* Resize with rotate, sharpen - http://imageproxy.niiknow.org/rx/100,r_90,e_50/https://static.pexels.com/photos/104827/cat-pet-animal-domestic-104827.jpeg
![Resize with rotate, sharpen](http://imageproxy.niiknow.org/rx/100,r_90,e_50/https://static.pexels.com/photos/104827/cat-pet-animal-domestic-104827.jpeg)

* Crop with gravity - http://imageproxy.niiknow.org/rx/100x100,c_1,g_Center/https://static.pexels.com/photos/104827/cat-pet-animal-domestic-104827.jpeg
![Crop with gravity](http://imageproxy.niiknow.org/rx/100x100,c_1,g_Center/https://static.pexels.com/photos/104827/cat-pet-animal-domestic-104827.jpeg)

# MIT
