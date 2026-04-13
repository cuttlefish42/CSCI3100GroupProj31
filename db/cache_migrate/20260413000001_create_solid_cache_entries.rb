class CreateSolidCacheEntries < ActiveRecord::Migration[8.1]
  def up
    load Rails.root.join("db/cache_schema.rb")
  end
end
