class ChangeLatitudeLongitudeToFloat < ActiveRecord::Migration[8.1]
  def change
    change_column :items, :latitude, :float
    change_column :items, :longitude, :float
  end
end
