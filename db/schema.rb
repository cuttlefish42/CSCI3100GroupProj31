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

ActiveRecord::Schema[8.1].define(version: 2026_03_19_185949) do
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

  create_table "items", force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "community_id"
    t.integer "condition", default: 0
    t.datetime "created_at", null: false
    t.decimal "price"
    t.integer "seller_id", null: false
    t.integer "status", default: 0
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["community_id"], name: "index_items_on_community_id"
    t.index ["seller_id"], name: "index_items_on_seller_id"
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
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["default_community_id"], name: "index_users_on_default_community_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "items", "categories"
  add_foreign_key "items", "communities"
  add_foreign_key "items", "users", column: "seller_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "communities", column: "default_community_id"
end
