module Spree::SpreePriceBooks::UserDecorator
  # When prices are determined based on the user role we must also include nil.
  def price_book_role_ids
    [nil, spree_roles.pluck(:id)].flatten
  end
end

Spree::user_class.prepend Spree::SpreePriceBooks::UserDecorator
