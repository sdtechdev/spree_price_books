module Spree::SpreePriceBooks::RoleDecorator
  def self.prepended(base)
    base.has_many :price_books
    base.scope :with_price_book, -> { where(id: Spree::PriceBook.pluck(:role_id).uniq) }
  end
end

Spree::Role.prepend Spree::SpreePriceBooks::RoleDecorator
