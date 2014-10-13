require 'logger'
require 'date'
require 'hashie'

class NullLogger < Logger
  def initialize(*args); end
  def add(*args, &block); end
end

module Lstash

  class Client

    class ConnectionError < StandardError; end

    PER_PAGE = 5000.freeze # best time, lowest resource usage

    def initialize(es_client, options = {})
      raise ConnectionError, "No elasticsearch client specified" if es_client.nil?

      @es_client = es_client
      @logger    = options[:logger] || (options[:debug] ? debug_logger : NullLogger.new)
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
      @logger.debug "time range: [%s..%s]" % [query.time_range.from, query.time_range.to]

      query.indices.each do |index|
        grep_messages(index, query) do |message|
          yield message if block_given?
        end
      end
    end

    private

    def count_messages(index, query)
      result = Hashie::Mash.new @es_client.send(:count,
        index: index,
        body:  query.body[:query]
      )
      @logger.debug "count #{index}: #{result['count']} "
      result['count']
    end

    def grep_messages(index, query)
      messages = nil
      scroll_params = {}
      offset = 0
      method = :search
      while (messages.nil? || messages.count > 0) do
        result = Hashie::Mash.new @es_client.send(method, {
          index: index,
          scroll: '10m',
          body: query.body.merge(from: offset, size: PER_PAGE),
        }.merge(scroll_params))

        messages = result.hits.hits

        offset += messages.count
        scroll_params = {scroll_id: result._scroll_id}

        messages.each do |h|
          next if h.fields.nil?
          yield h.fields.message if block_given?
        end

        method = :scroll
      end
      @logger.debug "grep #{index}: #{offset}"
      Hashie::Mash.new @es_client.clear_scroll(scroll_params)
    end

    def debug_logger
      logger = Logger.new(STDERR)
      logger.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
      end
      logger
    end

  end

end
