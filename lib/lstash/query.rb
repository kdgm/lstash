require 'time'
require 'date'
require 'ostruct'

module Lstash

  class Query

    class FormatError < StandardError; end
    class QueryMissing < StandardError; end

    LOGSTASH_PREFIX = 'logstash-'.freeze
    WILDCARD_QUERY  = '*'.freeze

    def initialize(query = nil, arguments = {})
      @query = query

      @anchor = time_parse(arguments[:anchor], 'today')
      @from   = time_parse(arguments[:from],   'today')
      @to     = time_parse(arguments[:to],     'now')

      @to = Time.now if @to > Time.now # prevent accessing non-existing times / indices
    end

    def time_range
      OpenStruct.new(from: @from, to: @to)
    end

    def date_range
      (@from.utc.to_date .. @to.utc.to_date)
    end

    def indices
      date_range.map { |d| "#{LOGSTASH_PREFIX}#{d.strftime('%Y.%m.%d')}" }
    end

    def body
      {
        sort: sort_order,

        fields: %w(message),

        # return in order of ascending timestamp
        query: {
          filtered: {
            query:  es_query,
            filter: es_filter
          }
        }
      }
    end

    private

    def time_parse(time_string, default)
      time_string = time_string.strip rescue nil
      time_string ||= default
      case time_string
      when 'firstday'
        midnight_at_beginning_of_month
      when 'now'
        Time.now
      when 'today'
        midnight_today
      when 'yesterday'
        midnight_yesterday
      else
        Time.parse(time_string)
      end
    rescue ArgumentError
      raise FormatError, "Invalid time format: #{time_string}"
    end

    def query
      q = @query.dup.strip rescue ''
      q = WILDCARD_QUERY if q.empty?
      q
    end

    def sort_order
      [ { '@timestamp' => { order: 'asc' } } ]
    end

    def es_query
      {
        bool: {
          should: [
            {
              query_string: {
                query: query
              }
            }
          ]
        }
      }
    end

    def es_filter
      {
        bool: {
          must: [
            range: {
              '@timestamp' => {
                from: to_msec(time_range.from),
                to:   to_msec(time_range.to)
              }
            },
            # fquery: {
            #   query: {
            #     query_string: {
            #       query: query
            #     }
            #   }
            # }
          ],
          # must_not: [
          #   fquery: {
          #     query: {
          #       query_string: {
          #         query: query
          #       }
          #     }
          #   }
          # ],
          # should: [
          #   fquery: {
          #     query: {
          #       query_string: {
          #         query: query
          #       }
          #     }
          #   }
          # ]
        }
      }
    end

    # Return the date of the first day of date's month
    def midnight_at_beginning_of_month
      Date.new(anchor_time.year, anchor_time.month, 1).to_time
    end

    def midnight_today
      Date.today.to_time
    end

    def midnight_yesterday
      (Date.today-1).to_time
    end

    def anchor_time
      @anchor
    end

    def to_msec(time)
      time.to_i * 1000
    end

  end

end
