BgSecure Plugin
===============

Provides access methods for generating secure urls on BitGravity.


Usage
-----

Create secure urls for Bit Gravity by passing the url, your Bit Gravity shared secret key, and an optional options hash.

Valid options:

* :expires - An object respending to :to_time, or and integer for seconds since UTC Epoch. If this option is not passed, evaluates to false, or if 0 is passed, the url will not expire.
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


Copyright (c) 2008 Martin Emde / La Touraine, Inc.
Released under the MIT license
