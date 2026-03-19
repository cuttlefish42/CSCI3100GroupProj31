class AddMoreFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :username, :string
    add_reference :users, :default_community, null: true, foreign_key: { to_table: :communities }
  end
end
