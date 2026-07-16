class Order < ApplicationRecord
  belongs_to :user
  belongs_to :product
  belongs_to :voucher, optional: true

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }
end
