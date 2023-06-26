## Release 1.0.0

* BREAKING CHANGE: default options changed
  * Default --from today changed to --from yesterday
  * Default --to now changed to --to today
  * This ensures that by default lstash counts or greps in yesterdays logging.
* Fixed bug which caused empty range (e.g. --from today --to today) to incorrectly return non-zero count and logging.
* Upgrade elasticsearch gem from version ~> 0.4 to ~> 7.17.7.
* Update queries and field selectors to be compatible with Elasticsearch version 7.
* Increase scroll step size for grep from 2 minutes to 1 hour (current Elasticsearch can handle it).
* Add --wildcard / --no-wildcard option to use logstash-* wildcard instead of iterating over indices directly.
  * For the count command --wildcard is faster so that's the default for count.
  * For the grep command --no-wildcard is faster so that's the default for grep.
* Dockerize development and add GitHub action for testing.
* Moved repo from kdgm/lstash to kdgm/lstash.
* Rubocop fixes

## Release 0.2.0

Merge branch 'feature/fix/hashie-warnings' into develop

* [fix] pin faraday to a compatible version
* [enh] upgrade to ruby 2.4(.6)
* [fix] suppress Hashie warnings; it would generate a warning for each log line (on stdout) leading to very large output

### 0.1.4 / 2015-05-29

Enhancements

* Change default time steps from 1 hour to 120 seconds to aid in grepping from datasets with many events per minute.

### 0.1.3 / 2015-05-28

Enhancements

* Remove troublesome development dependencies (autotest).

### 0.1.2 / 2015-01-02

Enhancements

* Double Elasticsearch::Client request timeout to 120 seconds to prevent Timeout::Error (Faraday::TimeoutError).

### 0.1.1 / 2014-10-13

Enhancements

* Refactor to iterate over hour periods instead of full indices. This improves the performance a lot.
* Increase timeout to prevent Faraday::TimeoutError exceptions.

### 0.0.9 / 2014-09-22

Enhancements

* We only every print the 'message' field. To optimize we only query for the 'message' field
  to be returned in the results. This should cut down the size of the returned json documents
  which could potentially be (very) large.

### 0.0.8 / 2014-09-01

Bug Fixes

* Require missing 'uri' (instead of using typhoed or patron HTTP transport clients).

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
