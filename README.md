# nginx image proxy
>High Performance and Low Resource Utilization Microservice

image cropping with gravity, resize and compress on the fly with nginx **image_filter** module.  A tiny docker container to build your own Cloudinary-like service.

Nginx module - https://github.com/niiknow/docker-nginx-image-proxy/blob/master/build/ngx_http_image_filter_module.c

Original File - https://github.com/niiknow/docker-nginx-image-proxy/blob/master/build/src/http/modules/ngx_http_image_filter_module.c

Patch creation: `diff -u src/http/modules/ngx_http_image_filter_module.c ngx_http_image_filter_module.c > image_filter.patch`

Patch apply with: `patch src/http/modules/ngx_http_image_filter_module.c image_filter.patch`

Features:
- [x] image crop offset, credit: https://github.com/bobrik/nginx_image_filter
- [x] /healthcheck endpoint
- [x] empty gif on other errors: 403, 404, 415, 500, 502, 503, 504
- [x] convert/force output to another format, support formats: bmp, jpg, png, gif, webp, and tiff 
- [x] use custom ssl and saved config when you mount '/app' volume.  nginx logs has also been redirect so you can backup, such as aws s3 sync.  Just delete the default redirect to stdout/access.log and stderr/error.log files.
- [x] support international characters in URL
- [x] automatically follow redirect at origin 
- [x] overridable nginx config - easily add secure link or additional nginx config
- [x] watermark with
```shell
# file must be png
image_filter_water_image /path/to/file/watermark.png;

# optional watermark positioning
image_filter_water_pos [ top-left | top-right | center | bottom-left | bottom-right (default)];
```
> TIP: The implementation of watermark feature, at the moment, is a very naive one.  Due to limited functionality, it add watermark after the image has been resized.  It work best when resize to smaller image/thumbnail and use in combination of a smaller watermark image.  We may expand on the functionality in the future, if we have time.

- [x] resize support image scale (enlarge image)
```shell
# optional scale max ratio, default 1
# becareful not to set this too high or it will use too much memory.
# 
# For example a 200KB JPEG file (1024x768) will take up 4MB of memory 
# when loaded; but when resampled to twice the the size, the memory 
# use jumps to 20.1MB
image_filter_scale_max 3;
```

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
![Dynamic Height](http://imageproxy.niiknow.org/rx/50/https://octodex.github.com/images/codercat.jpg?asdf)

* Dynamic Width - http://imageproxy.niiknow.org/rx/x100/https://octodex.github.com/images/codercat.jpg
![Dynamic Width](http://imageproxy.niiknow.org/rx/x100/https://octodex.github.com/images/codercat.jpg?asdf)

* Fix Width and Height, fit - http://imageproxy.niiknow.org/rx/200x500/https://static.pexels.com/photos/104827/cat-pet-animal-domestic-104827.jpeg
![Fix Width and Height - fit](http://imageproxy.niiknow.org/rx/200x500/https://static.pexels.com/photos/104827/cat-pet-animal-domestic-104827.jpeg?asdf)

* Resize with rotate, sharpen - http://imageproxy.niiknow.org/rx/100,r_90,e_50/https://static.pexels.com/photos/104827/cat-pet-animal-domestic-104827.jpeg
![Resize with rotate, sharpen](http://imageproxy.niiknow.org/rx/100,r_90,e_50/https://static.pexels.com/photos/104827/cat-pet-animal-domestic-104827.jpeg?asdf)

* Crop with gravity - http://imageproxy.niiknow.org/rx/100x100,c_1,g_Center/https://static.pexels.com/photos/104827/cat-pet-animal-domestic-104827.jpeg
![Crop with gravity](http://imageproxy.niiknow.org/rx/100x100,c_1,g_Center/https://static.pexels.com/photos/104827/cat-pet-animal-domestic-104827.jpeg?asdf)

* Scale with watermark - http://imageproxy.niiknow.org/rx/2000,water_1/https://octodex.github.com/images/codercat.jpg
![Scale with watermark](http://imageproxy.niiknow.org/rx/2000,water_1/https://octodex.github.com/images/codercat.jpg)

# Point of Interest
* [images.weserv.nl](https://github.com/weserv/images) is another great project to look at if you need additional features with image resizing.  The original purpose of this library (nginx-image-proxy) is to provide high performance and low resource utilization image private microservice.  We searched high and low but did not find a good solution.  At that time, we saw great potential with images.weserv.nl, but was held back because it was using php.  Since July 2018, it was rewritten with lua and direct c binding; as a result, it has became the next best solution and continue to improve.  The authors also generiously provide free endpoint for public use.  This help prove their implementation to be well battle-tested for use in any production environment.
> Update, as of September 2019, images.weserv.nl was rewritten again as C++ so it has now became the better/best choice.  We are now sun-setting this project, only maintenance and security support - no new feature, for the future date of December 2021 or 2 years from December 2019.

# MIT
