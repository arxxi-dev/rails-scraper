# frozen_string_literal: true

require 'nokogiri'

# This class is responsible to scrape the fields in given url
class Scrape
  SUPPORTED_URL_SCHEMES = %w[http https].freeze

  def initialize(url, fields)
    @url = url
    @fields = fields
  end

  def call
    page_content = fetch_page_content(@url)
    data = scrape_data(page_content)
    build_response(data)
  rescue StandardError => e
    build_response(nil, e.message)
  end

  private

  def fetch_page_content(url)
    uri = URI.parse(url)

    return unless safe_url?(uri)

    URI.open(uri).read
  rescue OpenURI::HTTPError => e
    raise StandardError, "HTTP Error: #{e.message}"
  end

  def scrape_data(page_content)
    parsed_data = Nokogiri::HTML(page_content)
    @fields.each_with_object({}) do |(field_name, selector), result|
      result[field_name] = parsed_data.css(selector)&.text&.strip
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