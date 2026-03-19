class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items do |t|
      t.string :title
      t.decimal :price
      t.integer :condition, default: 0
      t.integer :status, default: 0
      t.references :category, null: false, foreign_key: true
      t.references :community, null: true, foreign_key: true # Allow be put under "Global" community
      t.references :seller, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
