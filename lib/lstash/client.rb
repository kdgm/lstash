require "logger"
require "date"

class NullLogger < Logger
  def initialize(*args)
  end

  def add(*args, &block)
  end
end

module Lstash
  class Client
    class ConnectionError < StandardError; end

    class ShardMismatchError < StandardError; end

    PER_PAGE = 5000 # best time, lowest resource usage
    DEFAULT_COUNT_STEP = 3600 # 1 hour
    DEFAULT_GREP_STEP = 3600 # 1 hour # 120  # 2 minutes

    def initialize(es_client, options = {})
      raise ConnectionError, "No elasticsearch client specified" if es_client.nil?

      @es_client = es_client
      @logger = options[:logger] || (options[:debug] ? debug_logger : NullLogger.new)
    end

    def count(query, step = DEFAULT_COUNT_STEP)
      @logger.debug "count from=#{query.from} to=#{query.to}"

      count = 0
      query.each_period(step) do |index, hour_query|
        count += count_messages(index, hour_query)
      end
      @logger.debug "total count=#{count}"
      count
    end

    def grep(query, step = DEFAULT_GREP_STEP)
      @logger.debug "grep from=#{query.from} to=#{query.to}"

      count = 0
      query.each_period(step) do |index, hour_query|
        grep_messages(index, hour_query) do |message|
          count += 1
          yield message if block_given?
        end
      end

      @logger.debug "total count=#{count}"
      count
    end

    private

    def count_messages(index, query)
      result = @es_client.count(index: index, body: {query: query.filter})
      validate_shards!(result["_shards"])
      @logger.debug "count index=#{index} from=#{query.from} to=#{query.to} count=#{result["count"]}"
      result["count"]
    end

    def grep_messages(index, query)
      messages = nil
      scroll_params = {}
      offset = 0
      method = :search
      while messages.nil? || messages.count > 0
        result = @es_client.send(method, {
          index: index,
          scroll: "5m",
          body: query.search(offset, PER_PAGE)
        }.merge(scroll_params))

        validate_shards!(result["_shards"])

        messages = result["hits"]["hits"]
        offset += messages.count
        scroll_params = {scroll_id: result["_scroll_id"]}

        messages.each do |h|
          next if h["_source"].nil?
          yield h["_source"]["message"] if block_given?
        end

        method = :scroll
      end
      @logger.debug "grep index=#{index} from=#{query.from} to=#{query.to} count=#{offset}"
      @es_client.clear_scroll(scroll_params) unless scroll_params.empty?
    end

    def debug_logger
      logger = Logger.new($stderr)
      logger.formatter = proc do |severity, datetime, progname, msg|
        "#{datetime} #{msg}\n"
      end
      logger
    end

    def validate_shards!(shards)
      if shards["total"] != shards["successful"]
        raise ShardMismatchError, "Shard mismatch: total: #{shards["total"]}, successful: #{shards["successful"]}"
      end
    end
  end
end
