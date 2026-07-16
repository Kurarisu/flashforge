class VoucherCheckoutService
  def initialize(user:, product:, voucher_code:, quantity: 1)
    @user = user
    @product = product
    @voucher_code = voucher_code
    @quantity = quantity.to_i
  end

  def execute
    validate_quantity!
    @voucher = find_voucher!
    validate_stock!

    ActiveRecord::Base.transaction do
      @product.checkout!(@quantity)
      @voucher.redeem!
      discounted_unit = discounted_price
      order = Order.create!(user: @user, product: @product, quantity: @quantity, unit_price: discounted_unit, total_price: discounted_unit * @quantity, voucher: @voucher)
      ProductCacheService.clear
      order
    end
  end

  private

  def validate_quantity!
    raise ArgumentError, "quantity must be at least 1" if @quantity < 1
  end

  def find_voucher!
    voucher = Voucher.find_by(code: @voucher_code)
    raise ActiveRecord::RecordNotFound, "Voucher not found" unless voucher
    raise StandardError, "Voucher is not valid" unless voucher.valid_for_use?
    voucher
  end

  def validate_stock!
    raise StandardError, "out of stock" if @product.stock < @quantity
  end

  def discounted_price
    @product.price * (1 - @voucher.discount)
  end

  def voucher
    @voucher
  end
end
