# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'

# This class is responsible to scrape the fields in given url
class Scrape
  SUPPORTED_URL_SCHEMES = %w[http https].freeze
  META_FIELD = 'meta'
  UNSUPPORTED_URL_SCHEME = 'This URL is not supported'

  def initialize(url, fields)
    @url = url
    @fields = fields
    @result = {}
  end

  def call
    page_content = fetch_page_content
    scrape_data(page_content)
    build_response(@result)
  rescue StandardError => e
    build_response(nil, e.message)
  end

  private

  def fetch_page_content
    uri = URI.parse(@url)

    raise StandardError, UNSUPPORTED_URL_SCHEME unless safe_url?(uri)

    URI.open(uri).read
  rescue OpenURI::HTTPError => e
    raise StandardError, "HTTP Error: #{e.message}"
  end

  def scrape_data(page_content)
    parsed_data = Nokogiri::HTML(page_content)
    scrape_fields_with_css_selectors(parsed_data)
    scrape_fields_with_meta_attr(parsed_data)
  end

  def scrape_fields_with_css_selectors(parsed_data)
    @fields.each do |field_name, selector|
      @result[field_name] = parsed_data.css(selector)&.text&.strip
    end
  end

  def scrape_fields_with_meta_attr(parsed_data)
    return if @fields[:meta].empty?

    @result[:meta] = @fields[:meta].each_with_object({}) do |meta_attr, meta_result|
      meta_result[meta_attr] = parsed_data.at_css("meta[name='#{meta_attr}']")[:content]
    end
  end

  def safe_url?(uri)
    uri.scheme && SUPPORTED_URL_SCHEMES.include?(uri.scheme.downcase)
  end

  def build_response(data = nil, errors = [])
    {
      data: data,
      errors: errors
    }
  end
end
