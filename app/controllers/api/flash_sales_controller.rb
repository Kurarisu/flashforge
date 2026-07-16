module Api
  class FlashSalesController < ApplicationController
    protect_from_forgery with: :null_session

    def index
      flashsales = FlashSale.includes(:product).all
      render json: flashsales.as_json(include: { product: { only: [:id, :name, :price, :stock] } })
    end

    def create
      product = Product.find(flashsale_params[:product_id])
      flashsale = product.build_flash_sale(flashsale_params.except(:product_id))
      flashsale.save!
      render json: flashsale.as_json(include: { product: { only: [:id, :name, :price] } }), status: :created
    rescue ActiveRecord::RecordInvalid => error
      render json: { error: error.record.errors.full_messages }, status: :unprocessable_entity
    rescue ActiveRecord::RecordNotFound => error
      render json: { error: error.message }, status: :not_found
    end

    private

    def flashsale_params
      params.require(:flashsale).permit(:product_id, :flash_price, :flash_stock, :start_at, :end_at)
    end
  end
end
