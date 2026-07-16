module Api
  class OrdersController < ApplicationController
    protect_from_forgery with: :null_session

    def index
      orders = Order.includes(:user, :product, :voucher).all
      render json: orders.as_json(include: { user: { only: [:id, :name, :email] }, product: { only: [:id, :name, :price] }, voucher: { only: [:id, :code, :discount] } })
    end
  end
end
