# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_07_15_033108) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "flash_sales", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.decimal "flash_price"
    t.integer "flash_stock"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_flash_sales_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.decimal "total_price", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "voucher_id"
    t.index ["product_id"], name: "index_orders_on_product_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
    t.index ["voucher_id"], name: "index_orders_on_voucher_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "stock", default: 0, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "vouchers", force: :cascade do |t|
    t.string "code", null: false
    t.decimal "discount", precision: 5, scale: 4, default: "0.0", null: false
    t.integer "max_usage", default: 1, null: false
    t.integer "used_count", default: 0, null: false
    t.datetime "expired_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_vouchers_on_code", unique: true
  end

  add_foreign_key "flash_sales", "products"
  add_foreign_key "orders", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "orders", "vouchers"
end
