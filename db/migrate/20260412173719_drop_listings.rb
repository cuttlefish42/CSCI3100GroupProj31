class DropListings < ActiveRecord::Migration[8.1]
  def change
    drop_table :listings, if_exists: true do |t|
      t.text :description
      t.decimal :price
      t.string :title

      t.timestamps
    end
  end
end
