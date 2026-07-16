# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.find_or_create_by!(email: "alice@example.com") do |user|
  user.name = "Alice"
end

User.find_or_create_by!(email: "bob@example.com") do |user|
  user.name = "Bob"
end

standard_widget = Product.find_or_initialize_by(name: "Standard Widget")
standard_widget.description = "A reliable widget for everyday use."
standard_widget.price = 19.99
standard_widget.stock = 10
standard_widget.save!

premium_widget = Product.find_or_initialize_by(name: "Deluxe Widget")
premium_widget.description = "A premium widget with extra features."
premium_widget.price = 39.99
premium_widget.stock = 5
premium_widget.save!

Voucher.find_or_create_by!(code: "DISCOUNT10") do |voucher|
  voucher.discount = 0.10
  voucher.max_usage = 50
  voucher.used_count = 0
  voucher.expired_at = 30.days.from_now
end

Voucher.find_or_create_by!(code: "DISCOUNT20") do |voucher|
  voucher.discount = 0.20
  voucher.max_usage = 25
  voucher.used_count = 0
  voucher.expired_at = 60.days.from_now
end

Voucher.find_or_create_by!(code: "FIRST5") do |voucher|
  voucher.discount = 0.05
  voucher.max_usage = 100
  voucher.used_count = 0
  voucher.expired_at = 7.days.from_now
end

# Create flashsale for Standard Widget
standard_widget = Product.find_by(name: "Standard Widget")
if standard_widget
  FlashSale.find_or_create_by!(product_id: standard_widget.id) do |fs|
    fs.flash_price = 9.99
    fs.flash_stock = 50
    fs.start_at = Time.current
    fs.end_at = 2.hours.from_now
  end
end

# Create flashsale for Deluxe Widget
deluxe_widget = Product.find_by(name: "Deluxe Widget")
if deluxe_widget
  FlashSale.find_or_create_by!(product_id: deluxe_widget.id) do |fs|
    fs.flash_price = 24.99
    fs.flash_stock = 30
    fs.start_at = Time.current
    fs.end_at = 2.hours.from_now
  end
end
