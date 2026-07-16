class FlashSale < ApplicationRecord
  belongs_to :product

  validates :flash_price, numericality: { greater_than_or_equal_to: 0 }
  validates :flash_stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :end_at_after_start_at

  def active?
    return false if start_at.present? && start_at.future?
    return false if end_at.present? && end_at.past?
    true
  end

  def checkout!(quantity = 1)
    quantity = quantity.to_i
    raise ArgumentError, "quantity must be at least 1" if quantity < 1
    raise StandardError, "flashsale not active" unless active?
    raise StandardError, "flashsale out of stock" if flash_stock < quantity

    with_lock do
      raise StandardError, "flashsale out of stock" if reload.flash_stock < quantity
      update!(flash_stock: flash_stock - quantity)
    end
  end

  private

  def end_at_after_start_at
    return if end_at.blank? || start_at.blank?
    errors.add(:end_at, "must be after start_at") if end_at <= start_at
  end
end
