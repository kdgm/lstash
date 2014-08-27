# lstash

Lstash is a gem and command line utility to count or grep raw log messages in a certain time frame from a (logstash) elasticsearch server. 

## Installation

Or install it yourself as:

    $ gem install lstash

## Running lstash from the command line

lstash has two basic commands

* lstash count
* lstash grep

## Configuration

At a minimum you need to set the ES_URL environment variable where the logstash database can be reached.

    ES_URL=http://logstash.mydomain.com:9200

## Examples

Count the number of log messages matching QUERY from Aug 1 00:00 upto (not including) Aug 2 00:00

    lstash count QUERY --from "Aug 1" --to "Aug 2"

Download the raw messages (message field) using grep from Aug 1 00:00 upto (not including) Aug 21 00:00

    lstash grep QUERY --from "Aug 1" --to "Aug 21"

## Using lstash as a gem in your project

Add this line to your application's Gemfile:

    gem 'lstash'

And then execute:

    $ bundle

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
