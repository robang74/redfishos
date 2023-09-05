## About www folder

This is the `/var/www` folder shared by `busybox httpd` while the RedFish OS
[recovery image](../../../README.md) is running. Its content is copyeighted
all rights reserved, as the [COPYRIGHT](COPYRIGHT) file claims. From a
technical point of view, it is just a simple index.html that dress and undress a
single HTML page with different tiles. Just to check that the httpd service is
correctly running and tracking down the connection for debugging. It does not
even support SSL/HTTPS because, at the moment, it is just a local network over a
USB data link web service and it is not supposed to be exposed, even if the
default configuration on `0.0.0.0:80` allows it to bind to every interface.
which is up at boot time, and possibly also those came up later.

If you like to play with it, clone the repository and then execute:

* `firefox file://$PWD/redfishos/recovery/ramdisk/var/www/index.html`

The copyright notice is a link to the `COPYRIGHT` file, and the button works
with a JavaScript embedded into the `index.html` dressing up the page with a
background tile randomly chosen among those available. Moreover, after the first
three buttons pressures, starts a roulette russe with a traditional 1/6 chance
to display the copyright notice and hide the button in such a way that the page
should be reloaded or left fixed. A very simple game, but amusing. An Easter egg
will be added in the future because an Easter egg should not be left behind.

Stay tuned!
