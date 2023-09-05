## About www folder

This is the `/var/www` folder shared by `busybox httpd` while the RedFish OS [recovery image](../../../README.md) is running. Its content is copyeighted all rights reserved as the [LICENSE](LICENSE) files claims. From the technical point of view, it is just a simple index.html that dress/undress a single HTML page with different tiles. Just to check that the httpd service is correctly running and track down the connection for debugging. It does not even support the SSL/HTTPS because at the moment, it is just a local network over a USB data link web service and it is not supposed to be exposed even if the default configuration on `0.0.0.0:80` allows it to bind to every interface which is up at the boot time and possibly also those came up later.

If you like to play with it, clone the repository and then execute:

* `firefox file://$PWD/redfishos/recovery/ramdisk/var/www/index.html`

The copyright notice is a link to `LICENSE` and the button works with a JavaScript embedded into the `index.html`. Very simple.
