class AddSplitKarmaToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :buyer_karma, :integer, default: 0, null: false
    add_column :users, :seller_karma, :integer, default: 0, null: false
  end
end