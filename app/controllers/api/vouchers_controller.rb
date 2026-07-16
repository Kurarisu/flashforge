module Api
  class VouchersController < ApplicationController
    protect_from_forgery with: :null_session

    def index
      vouchers = Voucher.order(created_at: :desc)
      render json: vouchers
    end

    def create
      voucher = Voucher.create!(voucher_params)
      render json: voucher, status: :created
    rescue ActiveRecord::RecordInvalid => error
      render json: { error: error.record.errors.full_messages }, status: :unprocessable_entity
    end

    def redeem
      voucher = Voucher.find_by(code: params[:code])
      return render json: { error: "Voucher not found" }, status: :not_found unless voucher

      voucher.redeem!
      render json: voucher
    rescue StandardError => error
      render json: { error: error.message }, status: :unprocessable_entity
    end

    private

    def voucher_params
      params.require(:voucher).permit(:code, :discount, :max_usage, :used_count, :expired_at)
    end
  end
end
