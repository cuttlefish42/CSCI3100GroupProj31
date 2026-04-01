class AddMeetupLocationToItems < ActiveRecord::Migration[8.1]
  def change
    add_column :items, :latitude, :decimal
    add_column :items, :longitude, :decimal
    add_column :items, :meetup_note, :string
  end
end
