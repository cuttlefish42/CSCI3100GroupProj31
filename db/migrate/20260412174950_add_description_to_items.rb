class AddDescriptionToItems < ActiveRecord::Migration[8.1]
  def change
    add_column :items, :description, :text
  end
end
