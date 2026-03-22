class CreateOffers < ActiveRecord::Migration[8.1]
  def change
    create_table :offers do |t|
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.references :item, null: false, foreign_key: true
      t.decimal :price_offered, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
