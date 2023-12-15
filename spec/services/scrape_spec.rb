# spec/services/scrape_spec.rb

require 'rails_helper'

RSpec.describe Scrape do
  describe '#call' do
    let(:url) { 'https://example.com' }
    let(:fields) { { title: '.content-heading', description: '.content-description', meta: ['description', 'keywords'] } }

    context 'when the URL is valid and the page is successfully scraped' do
      let(:page_content) { '<html><head><title>Page Title</title><meta name="description" content="Description"><meta name="keywords" content="Keywords"></head><body><h1 class="content-heading">Main Heading</h1><p class="content-description">Page content</p></body></html>' }

      before do
        allow(URI).to receive(:open).and_return(StringIO.new(page_content))
      end

      it 'returns a hash with scraped data' do
        result = described_class.new(url, fields).call
        expect(result[:errors]).to be_empty
        expect(result[:data][:title]).to eq('Main Heading')
        expect(result[:data][:description]).to eq('Page content')
        expect(result[:data][:meta]).to eq({ 'description' => 'Description', 'keywords' => 'Keywords' })
      end
    end

    context 'when there is an HTTP error during page fetch' do
      before do
        allow(URI).to receive(:open).and_raise(OpenURI::HTTPError.new('404 Not Found', nil))
      end

      it 'returns an error message in the response' do
        result = described_class.new(url, fields).call
        expect(result[:errors]).to include('HTTP Error: 404 Not Found')
        expect(result[:data]).to be_nil
      end
    end

    context 'when the URL scheme is not supported' do
      let(:invalid_url) { 'ftp://example.com' }

      it 'returns an error message in the response' do
        result = described_class.new(invalid_url, fields).call
        expect(result[:errors]).to include('This URL is not supported')
        expect(result[:data]).to be_nil
      end
    end

    context 'when there is a general error during scraping' do
      before do
        allow(URI).to receive(:open).and_return(StringIO.new('<html></html>'))
        allow_any_instance_of(Nokogiri::HTML::Document).to receive(:css).and_raise(StandardError, 'Scraping error')
      end

      it 'returns an error message in the response' do
        result = described_class.new(url, fields).call
        expect(result[:errors]).to include('Scraping error')
        expect(result[:data]).to be_nil
      end
    end
  end
end
