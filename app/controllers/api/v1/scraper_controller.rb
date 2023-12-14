# frozen_string_literal: true

module Api
  module V1
    # This api is responsible for returning after scraping the data as per params
    class ScraperController < ApplicationController
      before_action :scrape_params, :verify_params, only: :scrape

      def scrape
        result = Scrape.new(scrape_params[:url], scrape_params[:fields]).call

        if result[:data].present?
          render json: result[:data]
        else
          error_response(result[:errors])
        end
      end

      private

      def scrape_params
        params.permit(:url, :fields)
      end

      def verify_params
        result = MissingParameterHandler.new(scraping_params, %i[url fields]).call

        error_response(result[:errors]) unless result[:success]
      end

      def error_response(errors)
        render json: { error: errors }, status: :unprocessable_entity
      end
    end
  end
end
