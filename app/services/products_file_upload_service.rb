# frozen_string_literal: true

module ProductsFileUploadService
  ALLOWED_MIME_TYPES = %w[text/csv text/plain].freeze
  STORE = "#{Rails.root}/tmp"

  module_function

  def validate_upload(file)
    return :err, 'CSV upload error. No file provided.' unless file.instance_of?(ActionDispatch::Http::UploadedFile)

    return :err, 'CSV upload error. Invalid content-type.' unless ALLOWED_MIME_TYPES.include?(file.content_type)

    [:ok, 'File successfully uploaded and will be processed in the background.']
  end

  def persist_upload(tempfile)
    file_name = "products_#{Time.now.to_i}.csv"
    # Since files can be large, we don't copy them not take x2 disk space
    FileUtils.mv(tempfile.path, "#{STORE}/#{file_name}")
    # Preventing Tempfile's utilization
    ObjectSpace.undefine_finalizer(tempfile)
    file_name
  end
end
