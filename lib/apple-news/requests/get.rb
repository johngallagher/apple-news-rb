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

        add_query_string_to @url, params: params, key: :page_size

        res = http.get(@url, headers)
        JSON.parse(res.body)
      end

      private

      def add_query_string_to(url, params:, key:)
        return unless params.key?(key)

        url.query = encoded(camel_cased(key) => params[key])
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
