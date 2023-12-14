# frozen_string_literal: true

module Api
  module V1
    # This api is responsible for returning after scraping the data as per params
    class ScraperController < ApplicationController
      before_action :scraping_params

      def scrape
        byebug
      end

      private

      def scraping_params
        
      end
    end
  end
end
