class Product < ApplicationRecord
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  has_one :flash_sale, dependent: :destroy

  after_commit :clear_product_cache, on: [ :create, :update, :destroy ]

  def checkout!(quantity = 1)
    quantity = quantity.to_i

    raise ArgumentError, "quantity must be at least 1" if quantity < 1
    raise StandardError, "out of stock" if stock < quantity

    transaction do
      lock!
      update!(stock: stock - quantity)
    end
  end

  private

  def clear_product_cache
    ProductCacheService.clear
  end
end
