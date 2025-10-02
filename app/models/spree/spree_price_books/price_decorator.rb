module Spree::SpreePriceBooks::PriceDecorator
  def self.prepended(base)
    base.belongs_to :price_book

    base.has_many :store_price_books, through: :price_book

    base.validate :ensure_proper_currency
    base.validates :price_book_id, presence: true

    base.before_validation :ensure_price_book

    base.after_create :populate_children
    base.after_update :update_children

    base.delegate :product, to: :variant

    base.scope :by_currency, -> (currency_iso) { where(currency: currency_iso) }
    base.scope :by_role, -> (role_ids) { prioritized.where(spree_price_books: { role_id: role_ids }) }
    base.scope :by_store, -> (store_id) { joins(:store_price_books).where(spree_store_price_books: { store_id: store_id }) }
    base.scope :list, -> { prioritized.where(spree_price_books: { discount: false }) }
    base.scope :prioritized, -> { includes(:price_book).order('spree_price_books.priority DESC, spree_prices.amount ASC') }
  end

  private

  def ensure_price_book
    self.price_book ||= Spree::PriceBook.default
  end

  def ensure_proper_currency
    unless currency == price_book.currency
      errors.add(:currency, :match_price_book)
    end
  end

  def populate_children
    price_book.children.each do |book|
      if price = book.prices.find_by_variant_id(self.variant_id)
        price.update_attribute :amount, self.amount * book.price_adjustment_factor
      else
        book.prices.create amount: (self.amount * book.price_adjustment_factor), currency: book.currency, variant_id: self.variant_id
      end
    end
  end

  def update_children
    price_book.children.each do |book|
      if price = book.prices.find_by_variant_id(self.variant_id)
        price.update_attribute :amount, self.amount * book.price_adjustment_factor
      end
    end
  end
end

Spree::Price.prepend Spree::SpreePriceBooks::PriceDecorator
