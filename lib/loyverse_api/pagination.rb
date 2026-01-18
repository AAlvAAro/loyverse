module LoyverseApi
  class PaginatedCollection
    include Enumerable

    attr_reader :data, :cursor

    def initialize(data, cursor: nil)
      @data = data
      @cursor = cursor
    end

    def each(&block)
      @data.each(&block)
    end

    def has_more?
      !@cursor.nil? && !@cursor.empty?
    end

    def next_page?
      has_more?
    end

    def size
      @data.size
    end

    def empty?
      @data.empty?
    end

    def first
      @data.first
    end

    def last
      @data.last
    end

    def [](index)
      @data[index]
    end

    def to_a
      @data
    end
  end

  module Pagination
    def paginate(endpoint, params: {}, data_key:)
      all_data = []
      current_cursor = params[:cursor]

      loop do
        query_params = params.dup
        query_params[:cursor] = current_cursor if current_cursor

        response = @client.get(endpoint, params: query_params)

        page_data = response[data_key] || []
        all_data.concat(page_data)

        current_cursor = response["cursor"]
        break unless current_cursor && !current_cursor.empty?
      end

      all_data
    end

    def paginated_request(endpoint, params: {}, data_key:)
      response = @client.get(endpoint, params: params)
      data = response[data_key] || []
      cursor = response["cursor"]

      PaginatedCollection.new(data, cursor: cursor)
    end

    def auto_paginate(endpoint, params: {}, data_key:)
      if params[:auto_paginate] == false
        paginated_request(endpoint, params: params.except(:auto_paginate), data_key: data_key)
      else
        paginate(endpoint, params: params.except(:auto_paginate), data_key: data_key)
      end
    end
  end
end
