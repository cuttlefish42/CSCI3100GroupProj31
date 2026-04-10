class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :offer, null: false, foreign_key: true
      t.references :reviewer, null: false, foreign_key: { to_table: :users }
      t.references :reviewee, null: false, foreign_key: { to_table: :users }
      t.integer :role, null: false
      t.integer :rating, null: false
      t.text :comment

      t.timestamps
    end

    add_index :reviews, [ :offer_id, :role ], unique: true
  end
end