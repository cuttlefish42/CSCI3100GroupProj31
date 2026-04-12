class CreateItemSnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :item_snapshots do |t|
      t.references :item, null: false, foreign_key: true
      t.integer :views_count, null: false, default: 0
      t.integer :likes_count, null: false, default: 0
      t.datetime :recorded_at, null: false

      t.timestamps
    end

    add_index :item_snapshots, [ :item_id, :recorded_at ]
  end
end
