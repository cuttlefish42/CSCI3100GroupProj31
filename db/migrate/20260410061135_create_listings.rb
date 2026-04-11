class CreateListings < ActiveRecord::Migration[8.1]
  def change
    create_table :listings do |t|
      t.string :title
      t.decimal :price
      t.text :description

      t.timestamps
    end
  end
end
