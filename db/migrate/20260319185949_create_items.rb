class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items do |t|
      t.string :title
      t.decimal :price
      t.integer :condition
      t.integer :status
      t.references :category, null: false, foreign_key: true
      t.references :community, null: false, foreign_key: true
      t.references :seller, null: false, foreign_key: true

      t.timestamps
    end
  end
end
