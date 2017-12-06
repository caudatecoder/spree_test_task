# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductsFileUploadService do
  context 'validation' do
    it 'fails for non-file' do
      status, = ProductsFileUploadService.validate_upload("I'm a file! Trust me!")
      expect(status).not_to eq(:ok)
    end

    it 'fails for not allowed content-types' do
      upload = ActionDispatch::Http::UploadedFile.new(tempfile: Tempfile.new)
      status, = ProductsFileUploadService.validate_upload(upload)
      expect(status).not_to eq(:ok)
    end

    it 'succeed for CSV files' do
      upload = ActionDispatch::Http::UploadedFile.new(tempfile: Tempfile.new('sample.csv'))
      upload.content_type = 'text/csv' # Rails will set it automatically for uploads
      status, = ProductsFileUploadService.validate_upload(upload)
      expect(status).to eq(:ok)
    end
  end

  context 'persistance. ' do
    it 'Saves Tempfile for further processing' do
      @file_name = ProductsFileUploadService.persist_upload(Tempfile.new('sample.csv'))
      expect(File.file?("#{ProductsFileUploadService::STORE}/#{@file_name}")).to be(true)
    end

    after do
      FileUtils.rm("#{ProductsFileUploadService::STORE}/#{@file_name}")
    end
  end
end
