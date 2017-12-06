# frozen_string_literal: true

module ProductsFileUploadService
  class CsvLoader
    SEPARATOR = ';'
    ATTRIBUTES = %i[name description price available_on slug stock_total category].freeze

    def initialize(file_name)
      @file_path = "#{STORE}/#{file_name}"
    end

    def process
      file_enum = File.open(@file_path).each
      # Skipping first line with prop-names
      # Content of the first line can be used in the future to dynamically
      # detect fields
      file_enum.next

      file_enum.each do |line|
        attrs = parse_attributes(line)
        # We probably wanna save info about failed products to show it to admin
        next unless valid_product_line?(attrs)

        attrs = prepare_attributes(attrs)
        ApplicationRecord.transaction { save_product(attrs) }
      end.close

      FileUtils.rm(@file_path)
      'Success'
    rescue Errno::ENOENT
      "The file #{@file_path} was deleted or even never existed"
    end

    private

    def parse_attributes(line)
      values = line.squish.split(SEPARATOR)
      values.delete_at(0) # skipping empty element created by first separator
      ATTRIBUTES.zip(values).to_h
    end

    def valid_product_line?(attrs)
      attrs[:name].present? && attrs[:price].present? && attrs[:category].present?
    end

    def prepare_attributes(attrs)
      attrs[:price] = attrs[:price].tr(',', '.')
      attrs[:available_on] = attrs[:available_on].to_time
      attrs
    end

    def save_product(attrs)
      stock_total = attrs.delete(:stock_total)
      category = attrs.delete(:category)
      product = Spree::Product.where(name: attrs[:name]).first_or_initialize
      product.shipping_category = Spree::ShippingCategory.where(name: category).first_or_create
      product.attributes = attrs
      product.save!

      stock_item = product.stock_items.first_or_initialize
      stock_item.update!(count_on_hand: stock_total)
    end
  end
end
