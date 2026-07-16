class CreateFlashSales < ActiveRecord::Migration[7.2]
  def change
    create_table :flash_sales do |t|
      t.references :product, null: false, foreign_key: true
      t.decimal :flash_price
      t.integer :flash_stock
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps
    end
  end
end
