module Spree::SpreePriceBooks::StoreDecorator
  def self.prepended(base)
    base.has_many :price_books, -> {
      select("DISTINCT (#{table_name}.id), #{table_name}.*, #{Spree::StorePriceBook.table_name}.priority").
        order("#{Spree::StorePriceBook.table_name}.priority DESC")
    }, through: :store_price_books

    base.has_many :store_price_books
  end
end

Spree::Store.prepend Spree::SpreePriceBooks::StoreDecorator
