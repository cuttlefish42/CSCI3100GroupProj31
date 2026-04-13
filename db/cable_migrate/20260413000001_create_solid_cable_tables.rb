class CreateSolidCableTables < ActiveRecord::Migration[8.1]
  def up
    load Rails.root.join("db/cable_schema.rb")
  end
end
