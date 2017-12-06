# frozen_string_literal: true

Spree::Admin::ProductsController.class_eval do
  def csv_load
    status, msg = ProductsFileParserService.validate_upload(params[:csv])
    if status == :ok
      ProductsFileParserService.persist_upload(params[:csv].tempfile)
      flash[:success] = msg
    else
      flash[:error] = msg
    end

    redirect_to :admin_products
  end
end
