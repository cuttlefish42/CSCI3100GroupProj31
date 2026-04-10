# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_10_015119) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "communities", force: :cascade do |t|
    t.string "community_type"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "conversations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "receiver_id", null: false
    t.integer "sender_id", null: false
    t.datetime "updated_at", null: false
    t.index ["receiver_id"], name: "index_conversations_on_receiver_id"
    t.index ["sender_id"], name: "index_conversations_on_sender_id"
  end

  create_table "items", force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "community_id"
    t.integer "condition", default: 0
    t.datetime "created_at", null: false
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "meetup_note"
    t.decimal "price"
    t.integer "seller_id", null: false
    t.integer "status", default: 0
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["community_id"], name: "index_items_on_community_id"
    t.index ["seller_id"], name: "index_items_on_seller_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.integer "conversation_id", null: false
    t.datetime "created_at", null: false
    t.integer "item_id"
    t.integer "offer_id"
    t.integer "sender_id", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["item_id"], name: "index_messages_on_item_id"
    t.index ["offer_id"], name: "index_messages_on_offer_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "offers", force: :cascade do |t|
    t.integer "buyer_id", null: false
    t.decimal "counter_price"
    t.datetime "created_at", null: false
    t.integer "item_id", null: false
    t.text "message"
    t.decimal "price_offered", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_id"], name: "index_offers_on_buyer_id"
    t.index ["item_id"], name: "index_offers_on_item_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "default_community_id"
    t.string "email_address", null: false
    t.string "first_name"
    t.integer "karma", default: 0
    t.string "last_name"
    t.string "password_digest", null: false
    t.datetime "password_reset_sent_at"
    t.string "password_reset_token"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["default_community_id"], name: "index_users_on_default_community_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "conversations", "users", column: "receiver_id"
  add_foreign_key "conversations", "users", column: "sender_id"
  add_foreign_key "items", "categories"
  add_foreign_key "items", "communities"
  add_foreign_key "items", "users", column: "seller_id"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "items"
  add_foreign_key "messages", "offers"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "offers", "items"
  add_foreign_key "offers", "users", column: "buyer_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "communities", column: "default_community_id"
end
