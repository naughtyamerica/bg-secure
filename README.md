BgSecure Plugin
===============

Provides access methods for generating secure urls on [BitGravity](http://bitgravity.com).


Usage
-----

Create secure urls for Bit Gravity by passing the url, your Bit Gravity shared secret key, and an optional options hash.

    BgSecure.url_for(url, secret, options = {})

* url - Either a full url (http://example.com/path/file.ext) or a path (/path/file.ext) to the secure asset. The response will be returned the same as it was sent (with or without the host). A document relative path will cause an ArgumentError. A kind_of URI::HTTP may also be passed.
* secret - Your shared secret key from BitGravity.
* options - An optional hash of options (explained below).

Valid options:

* :expires - An object responding to :to_time, or and integer for seconds since UTC Epoch. If this option is not passed, evaluates to false, or if 0 is passed, the url will not expire.
* :unlock - If set to true, will override any country based blocking. This option takes precedence over :allowed and :disallowed so please pass only one of these options.
* :allowed - Either an array of countries ['US', 'CA'] or a string "US,CA" used to indicate allowed countries. This option will override :disallowed and be overridden by :unlock so please pass only one of these options.
* :disallowed - Either an array of countries ['US', 'CA'] or a string "US,CA" used to indicate disallowed countries. This option will be overridden by :unlock or :allowed so please pass only one of these options.

Examples
--------

Secure url that doesn't expire

    BgSecure.url_for('http://example.com/path/file.ext', 'secret')

> => "http://example.com/path/file.ext?e=0&h=74bea39e4aa13f08a6fc862fe29574fc"

Secure url that expires 2 days from now (time will be converted to UTC)

    BgSecure.url_for('http://example.com/path/file.ext', 'secret', :expires => 2.days.from_now)

> => "http://example.com/path/file.ext?e=1234567890&h=74bea39e4aa13f08a6fc862fe29574fc"

Secure url that doesn't expire but allows only US access

    BgSecure.url_for('http://example.com/path/file.ext', 'secret', :allowed => 'US')

> => "http://example.com/path/file.ext?e=0&a=US&h=0880d05de9eb8a67146473cbceca40e3"


Contributing
------------

There are RSpec examples included with the plugin. Please spec any contributions and we will be happy to merge your changes.


Copyright (c) 2008 Martin Emde / La Touraine, Inc.
Released under the MIT license
