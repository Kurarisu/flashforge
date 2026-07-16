class FlashsaleCheckoutService
  def initialize(user:, product:, quantity: 1)
    @user = user
    @product = product
    @quantity = quantity.to_i
  end

  def execute
    validate_quantity!
    flashsale = find_flashsale!
    request_id = SecureRandom.hex(4)

    Rails.logger.info("[flashsale][request=#{request_id}] queued product_id=#{@product.id} user_id=#{@user.id} quantity=#{@quantity} at=#{Time.current.iso8601}")

    ActiveRecord::Base.transaction do
      flashsale.checkout!(@quantity)
      order = Order.create!(
        user: @user,
        product: @product,
        quantity: @quantity,
        unit_price: flashsale.flash_price,
        total_price: flashsale.flash_price * @quantity
      )
      ProductCacheService.clear
      Rails.logger.info("[flashsale][request=#{request_id}] success order_id=#{order.id} at=#{Time.current.iso8601}")
      order
    end
  rescue StandardError => error
    Rails.logger.warn("[flashsale][request=#{request_id}] rejected error=#{error.message} at=#{Time.current.iso8601}")
    raise
  end

  private

  def validate_quantity!
    raise ArgumentError, "quantity must be at least 1" if @quantity < 1
  end

  def find_flashsale!
    flashsale = @product.flash_sale
    raise StandardError, "flashsale not found" unless flashsale
    raise StandardError, "flashsale not active" unless flashsale.active?
    flashsale
  end
end
