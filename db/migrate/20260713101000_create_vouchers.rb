class CreateVouchers < ActiveRecord::Migration[7.2]
  def change
    create_table :vouchers do |t|
      t.string :code, null: false
      t.decimal :discount, precision: 5, scale: 4, null: false, default: 0.0
      t.integer :max_usage, null: false, default: 1
      t.integer :used_count, null: false, default: 0
      t.datetime :expired_at

      t.timestamps
    end

    add_index :vouchers, :code, unique: true
  end
end
