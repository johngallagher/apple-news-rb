require 'spec_helper'
require 'json'

describe AppleNews::Request::Get do
  before do
    AppleNews.config.channel_id = 'abc'
    AppleNews.config.api_key_id = '379FFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'
    AppleNews.config.api_key_secret = 'miJAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='
  end

  context 'no query passed in' do
    it 'sends no query string' do
      stub_articles_api(
        with_query: {},
        to_return: article_data.to_json
      )
      response = request.call({})
      expect(response).to eq(article_data)
    end
  end

  context 'when asking for articles in pages of 100' do
    it 'passes the pageSize via the query string' do
      stub_articles_api(
        with_query: { 'pageSize' => 100 },
        to_return: article_data.to_json
      )
      response = request.call(page_size: 100)
      expect(response).to eq(article_data)
    end
  end

  context 'when asking for page token' do
    it 'passes the pageSize via the query string' do
      stub_articles_api(
        with_query: { 'pageToken' => 'abc' },
        to_return: article_data.to_json
      )
      response = request.call(page_token: 'abc')
      expect(response).to eq(article_data)
    end
  end

  context 'when asking for articles sorted by newest first' do
    it 'passes the sortDir via the query string' do
      stub_articles_api(
        with_query: { 'sortDir' => 'DESC' },
        to_return: article_data.to_json
      )
      response = request.call(sort_dir: 'DESC')
      expect(response).to eq(article_data)
    end

    it 'capitalizes the sort dir parameter' do
      stub_articles_api(
        with_query: { 'sortDir' => 'DESC' },
        to_return: article_data.to_json
      )
      response = request.call(sort_dir: :desc)
      expect(response).to eq(article_data)
    end
  end

  private

  def stub_articles_api(with_query:, to_return:)
    stub_request(:get, "#{AppleNews.config.api_base}#{url}")
      .with(query: with_query)
      .to_return(body: to_return)
  end

  def request
    AppleNews::Request::Get.new(url)
  end

  def url
    '/channels/abcd/articles'
  end

  def article_data
    { 'data' => [{ 'title' => 'Article title' }] }
  end
end
