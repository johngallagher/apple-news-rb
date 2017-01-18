module AppleNews
  module Request
    class Get
      attr_reader :url

      def initialize(url)
        @config = AppleNews.config
        @url = URI.parse(File.join(@config.api_base, url))
      end

      def call(params = {})
        http = Net::HTTP.new(@url.hostname, @url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER

        add_query_string_to @url, params: params, fields: [:page_size, :sort_dir, :page_token]

        res = http.get(@url, headers)
        JSON.parse(res.body)
      end

      private

      def add_query_string_to(url, params:, fields:)
        active_fields = params.keys & fields
        url.query = encoded(query params: params, fields: active_fields) if active_fields.any?
      end

      def query params:, fields:
        fields.inject({}) do |query, field|
          query.merge(camel_cased(field) => extract(field, from: params))
        end
      end

      def extract field, from:
        query_value = from[field]
        if query_value.is_a? Symbol
          query_value.to_s.upcase 
        else
          query_value
        end
      end

      def camel_cased key
        key.to_s.camelize(:lower)
      end

      def encoded(query)
        URI.encode_www_form(query)
      end

      def headers
        security = AppleNews::Security.new('GET', @url.to_s)
        { 'Authorization' => security.authorization }
      end
    end
  end
end
