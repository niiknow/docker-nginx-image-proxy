# docker-nginx-image-proxy
Image cropping with gravity, resizing and compressing on the fly with nginx image_filter module.  Docker container to build your own Cloudinary-like service.

For image crop offset, credit to: https://github.com/bobrik/nginx_image_filter

Crop gravity is very important to us.  We don't get why most image transformer default is set to Center.  Often, we find ourself using crop gravity NorthWest for large image teaser, especially in email.  This is why we have our default to NorthWest.  

# What does this solve?
You have a huge repository of images that need dynamic resize and cropping; which is the most common task of image transform.  You buy your own CDN so Cloudinary can be redundant and expensive.

# And what it doesn't?
This does not try to solve everything with image transformation.

1.  For more advanced features such as: animated gif, face detection, auto image optimization, and others; we recommend using Cloudinary or similar service.
2.  There is no plan for SSL or other Caching methods.  We recommend putting a CDN in front, such as (MaxCDN/StackPath/KeyCDN), to provide caching and easy SSL.
3.  If you want thumbnail caching to s3, just write a lambda function and use this server to generate your thumbnail.  Then upload to s3 with the same function.

# build
docker build -t nginx-image-proxy .

# run
docker run -d --restart=always -p 80:80 niiknow/nginx-image-proxy

url to new/dynamic server conf (a github raw or/perhap a github gist?):

--env SERVER_CONF='https://gist.githubusercontent.com/...'

# web
http://yourdomain.com/rx/url-options/http://remote-host.com/image-path/image.jpg

or no protocol (default http): http://yourdomain.com/rx/url-options/remote-host.com/image-path/image.jpg

Option Keys:
-------------

```yml
code: name - valid values - default
  q: quality - 1-100 - 96 (default best image just in case it's a jpg that already has been optimized) 
  w: width - uint - null
  h: height - uint - null
  c: crop - null, 1 - null
  rz: resize - null, 1 - 1
  g: gravity - NorthWest, North, NorthEast, West, Center, East, SouthWest, South, SouthEast *case-sensitive* - NorthWest
  e: sharpen - 1..100 - 95
  r: rotate - 0, 90, 180, 270 - 0
```

Options Usages:
----------------

Though options are mirrored of what you would get with Cloudinary, it also very flexible and customizable.

* Like Cloudinary with underscore (_) as separator:  OptionKey_OptionValue - g_Center, w_100, h_100
* Or without any separator: OptionKeyOptionValue - gCenter, w100, h100
* Or in a QueryString: ?g=Center&w=100&h=100

And if that doesn't work, you can always use your custom nginx config by passing the config url into docker run environment variable: SERVER_CONF

# Additional features
- [x] /healthcheck endpoint
- [x] 302 redirect to origin server on proxy error
- [x] empty gif on other errors: 403, 404, 500 or when URL is not on your whitelist

# Example 

Dynamic Height: http://yourdomain.com/rx/100/http://remote-host.com/image-path/image.jpg

Dynamic Width: http://yourdomain.com/rx/x100/http://remote-host.com/image-path/image.jpg

Fix Width and Height: http://yourdomain.com/rx/100x100/http://remote-host.com/image-path/image.jpg

Resize with rotate, sharpen: http://yourdomain.com/rx/100,r_90,e_50/http://remote-host.com/image-path/image.jpg

Crop with gravity: http://yourdomain.com/rx/100x100,c_1,g_Center/http://remote-host.com/image-path/image.jpg

Licence: MIT
