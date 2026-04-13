class CreateSolidQueueTables < ActiveRecord::Migration[8.1]
  def up
    load Rails.root.join("db/queue_schema.rb")
  end
end
