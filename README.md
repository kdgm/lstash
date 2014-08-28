# lstash

Lstash is a gem and command line utility to count or grep log messages in a certain time frame from a Logstash Elasticsearch server. 

## Installation

Or install it yourself as:

    $ gem install lstash

## Running lstash from the command line

	$ lstash
	Commands:
	  lstash count QUERY     # count number of log messages matching the QUERY
	  lstash grep QUERY      # grep log messages from Logstash
	  lstash help [COMMAND]  # Describe available commands or one specific command

## The `count` command

	Usage:
	  lstash count QUERY

	Description:
	  Count log messages matching the QUERY from Logstash and output this count to stdout. QUERY can use Apache Lucene query 
	  parser syntax.

	  Example to count the number of HAProxy log messages in yesterdays month.

	  lstash count 'program:haproxy' --from firstday --to today --anchor yesterday

## The `grep` command

	Usage:
	  lstash grep QUERY

	Description:
	  Grep log messages matching the QUERY from Logstash in ascending timestamp order and output to stdout. QUERY can use Apache Lucene query parser syntax.

	  Example to grep HAProxy log messages from the beginning of this month upto now

	  lstash grep 'program:haproxy' --from firstday --to now

## Command line options

	Options:
	  -f, [--from=start of time range]                    # date/time, 'now', 'today', 'yesterday', or 'firstday'
	  -t, [--to=end of time range]                        # date/time, 'now', 'today', 'yesterday', or 'firstday'
	  -a, [--anchor=anchor date/time]                     # used as reference date for firstday
	  -e, [--es-url=Elasticsearch endpoint for Logstash]  # or ES_URL environment variable

All times will be relative to the timezone of the machine on which you are running lstash.

## Elasticsearch configuration

By default `lstash` will connnect to Elasticsearch on your localhost as `http://localhost:9200`. To connect
to a different server you can set the `ES_URL` environment variable. URL scheme `http` and port `9200` are default
and may be omitted.

Example

    export ES_URL=log.mydomain.com
    lstash count program:haproxy

Or

	lstash count program:haproxy --es-url log.mydomain.com

## Examples

Count the number of haproxy log messages matching QUERY from Aug 1 at midnight (0:00 am) upto (not including) Aug 2 at midnight (0:00 am).

    lstash count program:haproxy --from "Aug 1" --to "Aug 2"

Grep all haproxy log messages using for one day (Aug 24 1 0:00 am upto and including Aug 2 23:59).

    lstash grep program:haproxy --from "Aug 1" --to "Aug 2"

Assuming today is Sep 1 2014. Count all haproxy log messages in the previous month.

	lstash count program:haproxy --anchor yesterday --from firstday --to today -d
	time range: [2014-08-01 00:00:00 +0200..2014-09-01 00:00:00 +0200]
	logstash-2014.07.31: 1 
	logstash-2014.08.01: 13 
	logstash-2014.08.02: 14 
	logstash-2014.08.03: 1654 
	logstash-2014.08.04: 6 
	logstash-2014.08.05: 20 
	logstash-2014.08.06: 219 
	logstash-2014.08.07: 32 
	logstash-2014.08.08: 14 
	logstash-2014.08.09: 28 
	logstash-2014.08.10: 799 
	logstash-2014.08.11: 18 
	logstash-2014.08.12: 8 
	logstash-2014.08.13: 23 
	logstash-2014.08.14: 25 
	logstash-2014.08.15: 69 
	logstash-2014.08.16: 19 
	logstash-2014.08.17: 1160 
	logstash-2014.08.18: 284 
	logstash-2014.08.19: 61 
	logstash-2014.08.20: 26 
	logstash-2014.08.21: 16 
	logstash-2014.08.22: 145 
	logstash-2014.08.23: 72 
	logstash-2014.08.24: 792 
	logstash-2014.08.25: 31 
	logstash-2014.08.26: 33 
	logstash-2014.08.27: 51 
	logstash-2014.08.28: 8 
	logstash-2014.08.29: 23 
	logstash-2014.08.30: 25 
	logstash-2014.08.31: 69 
	5633

## Using lstash as a gem in your project

Add this line to your application's Gemfile:

    gem 'lstash'

And then execute:

    $ bundle

Usage:

	$ bundle console

	# connect to elasticsearch and create the Lstash client
	elasticsearch = Elasticsearch::Client.new(url: 'log.mydomain.com')
	client = Lstash::Client.new(elasticsearch)

	# create the query
	query = Lstash::Query.new('program:haproxy', from: 'today', to: 'now')

	# count
	client.count(query)

	# grep
	client.grep(query) do |message|
	  puts message
	end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
