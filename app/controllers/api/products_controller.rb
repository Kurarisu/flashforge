module Api
  class ProductsController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :set_product, only: [ :checkout ]

    def index
      products = ProductCacheService.fetch_all
      render json: products
    end

    def checkout
      user = User.find(checkout_params[:user_id])
      quantity = checkout_params.fetch(:quantity, 1).to_i
      voucher_code = checkout_params[:voucher_code]
      use_flashsale = checkout_params[:use_flashsale] == "true"

      Rails.logger.info("[checkout] request product_id=#{@product.id} user_id=#{user.id} quantity=#{quantity} voucher_code=#{voucher_code} use_flashsale=#{use_flashsale} at=#{Time.current.iso8601}")

      order = if use_flashsale && @product.flash_sale&.active?
        FlashsaleCheckoutService.new(user: user, product: @product, quantity: quantity).execute
      elsif voucher_code.present?
        VoucherCheckoutService.new(user: user, product: @product, voucher_code: voucher_code, quantity: quantity).execute
      else
        ActiveRecord::Base.transaction do
          @product.checkout!(quantity)
          Order.create!(user: user, product: @product, quantity: quantity, unit_price: @product.price, total_price: @product.price * quantity)
        end
      end

      ProductCacheService.clear

      render json: order.as_json(include: { user: { only: [ :id, :name, :email ] }, product: { only: [ :id, :name, :price ] }, voucher: { only: [ :id, :code, :discount ] } }), status: :created
    rescue ActiveRecord::RecordNotFound => error
      render json: { error: error.message }, status: :not_found
    rescue ArgumentError => error
      render json: { error: error.message }, status: :unprocessable_entity
    rescue StandardError => error
      render json: { error: error.message }, status: :unprocessable_entity
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def checkout_params
      params.permit(:quantity, :user_id, :voucher_code, :use_flashsale)
    end
  end
end
