# frozen_string_literal: true

Spree::Admin::ProductsController.class_eval do
  def csv_load
    status, msg = ProductsFileUploadService.validate_upload(params[:csv])
    if status == :ok
      file_name = ProductsFileUploadService.persist_upload(params[:csv].tempfile)
      ProcessProductsCsvJob.perform_later(file_name)
      flash[:success] = msg
    else
      flash[:error] = msg
    end

    redirect_to :admin_products
  end
end
