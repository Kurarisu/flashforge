class Voucher < ApplicationRecord
  has_many :orders

  validates :code, presence: true, uniqueness: true
  validates :discount, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :max_usage, numericality: { only_integer: true, greater_than: 0 }
  validates :used_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def valid_for_use?
    return false if expired_at.present? && expired_at.past?
    used_count < max_usage
  end

  def redeem!
    raise StandardError, "Voucher has expired" if expired_at.present? && expired_at.past?
    raise StandardError, "Voucher usage limit reached" if used_count >= max_usage

    with_lock do
      raise StandardError, "Voucher usage limit reached" if reload.used_count >= max_usage
      increment!(:used_count)
    end
  end
end
