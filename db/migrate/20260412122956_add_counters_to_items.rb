class AddCountersToItems < ActiveRecord::Migration[8.1]
  def change
    add_column :items, :views_count, :integer, default: 0, null: false
    add_column :items, :likes_count, :integer, default: 0, null: false
  end
end
