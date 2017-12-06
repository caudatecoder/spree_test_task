# frozen_string_literal: true

class ProcessProductsCsvJob < ApplicationJob
  queue_as :default

  def perform(file_name)
    csv_loader = ProductsFileUploadService::CsvLoader.new(file_name)
    result = csv_loader.process

    # More complex handling can done here
    Rails.logger.info("ProcessProductsCsvJob completed. Status: #{result}")
  end
end
