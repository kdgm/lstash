### 0.0.7 / 2014-09-01

Bug Fixes

* Use Typhoed transport instead of Patron. The C-extension of Patron doesn't play nice with JRuby.

### 0.0.6 / 2014-09-01

Bug Fixes

* Pushing version 0.0.5 failed and it was yanked from rubygems.org. Need to push new version 0.0.6.

### 0.0.5 / 2014-09-01

Bug Fixes

* Running as binary didn't load HTTP client properly. Add 'patron' dependency
  to force loading an appropriate HTTP client.

### 0.0.4 / 2014-08-29

Bug Fixes

* Use .ruby-[version|gemset] to support any ruby environment manager.

### 0.0.3 / 2014-08-28

Bug Fixes

* Run CI on travis-ci.org.
* Fixate timezone to assumed timezone for specs.
* Run Ruby 2.1.1 instead of 2.1.0.

### 0.0.2 / 2014-08-28

Enhancements

* Updated documentation.
* Rename debug option (-v) to (-d).

### 0.0.1 / 2014-08-28

Initial release.
