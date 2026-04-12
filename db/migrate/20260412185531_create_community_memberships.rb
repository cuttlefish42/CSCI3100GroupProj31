class CreateCommunityMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :community_memberships do |t|
      t.references :community, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, default: 0, null: false

      t.timestamps
    end

    add_index :community_memberships, [ :community_id, :user_id ], unique: true
  end
end
