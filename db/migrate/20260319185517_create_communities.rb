class CreateCommunities < ActiveRecord::Migration[8.1]
  def change
    create_table :communities do |t|
      t.string :name
      t.string :community_type

      t.timestamps
    end
  end
end
