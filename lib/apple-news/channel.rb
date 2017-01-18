module AppleNews
  class Channel
    include Resource
    include Links

    attr_reader :id, :type, :name, :website, :links, :created_at, :modified_at,
                :default_section, :share_url

    def self.current
      new(AppleNews.config.channel_id)
    end

    def initialize(id, data = nil)
      @id = id
      @resource_path = '/channels'

      data.nil? ? hydrate! : set_read_only_properties(data)
    end

    def default_section
      Section.new(section_link_id('defaultSection'))
    end

    def sections
      request = Request::Get.new("/channels/#{id}/sections")
      resp = request.call
      resp['data'].map do |section|
        Section.new(section['id'], section)
      end
    end

    def articles(params = {})
      articles = []

      page = get_page(params)
      articles += page[:results]

      while page[:next_page]
        page = get_page(params.merge(page_token: page[:next_page]))
        articles += page[:results]
      end

      sorted_articles = articles.sort_by { |article| Date.parse(article.document.metadata['datePublished']) }
      sorted_articles.reverse! if params[:sort_dir].to_s.casecmp('desc').zero?
      sorted_articles
    end

    def get_page(params = {})
      request = Request::Get.new("/channels/#{id}/articles")
      response = request.call(params)
      results = response['data'].map do |article|
        Article.new(article['id'])
      end

      {
        results: results,
        next_page: next_page_token(response)
      }
    end

    def next_page_token(response)
      response['meta'] && response['meta']['nextPageToken']
    end
  end
end
