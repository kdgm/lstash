require 'logger'
require 'date'
require 'hashie'
require 'elasticsearch'

class NullLogger < Logger
  def initialize(*args); end
  def add(*args, &block); end
end

module Lstash

  class Client

    class ConnectionError < StandardError; end

    PER_PAGE = 5000 # best time, lowest resource usage

    def initialize(es_client, options = {})
      raise ConnectionError, "No elasticsearch client specified" if es_client.nil?

      @logger    = options[:logger] || (options[:verbose] ? verbose_logger : NullLogger.new)
      @es_client = es_client
    end

    def count(query)
      @logger.debug "time range: [%s..%s]" % [query.time_range.from, query.time_range.to]

      count = 0
      query.indices.each do |index|
        count += count_messages(index, query)
      end

      count
    end

    def grep(query)
      query.indices.each do |index|
        @logger.debug "grep #{index}"
        
        grep_messages(index, query) do |message|
          yield message if block_given?
        end
      end
    end

    private

    def count_messages(index, query)
      result = Hashie::Mash.new @es_client.send(:count,
        {
          index: index,
          body:  query.body[:query]
        }
      )
      @logger.debug "#{index}: #{result['count']} "
      result['count']
    end

    def grep_messages(index, query)
      result = nil
      scroll_params = {}
      offset = 0
      while (result.nil? || result.hits.hits.count > 0) do
        method = (result.nil? ? :search : :scroll)
        result = Hashie::Mash.new @es_client.send(method,
          {
            index: index,
            scroll: '10m',
            body: query.body.merge(from: offset, size: PER_PAGE),
          }.merge(scroll_params)
        )
        @logger.debug "Count #{result.hits.hits.count}"

        offset += result.hits.hits.count
        scroll_params = {scroll_id: result._scroll_id}

        result.hits.hits.each do |h|
          yield h._source.message if block_given?
        end
      end
      Hashie::Mash.new @es_client.clear_scroll(scroll_params)
    end

    def verbose_logger
      logger = Logger.new(STDOUT)
      logger.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
      end
      logger
    end

  end

end
