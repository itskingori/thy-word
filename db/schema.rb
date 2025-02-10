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

ActiveRecord::Schema[8.0].define(version: 2025_02_09_182503) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bibles", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", limit: 3, null: false
    t.text "statement", null: false
    t.string "rights_holder_name", null: false
    t.string "rights_holder_url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_bibles_on_code", unique: true
  end

  create_table "books", force: :cascade do |t|
    t.bigint "bible_id", null: false
    t.string "title", null: false
    t.integer "number", null: false
    t.string "code", limit: 3, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bible_id", "code"], name: "index_books_on_bible_id_and_code", unique: true
    t.index ["bible_id"], name: "index_books_on_bible_id"
  end

  create_table "chapters", force: :cascade do |t|
    t.bigint "bible_id", null: false
    t.bigint "book_id", null: false
    t.integer "number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bible_id", "book_id", "number"], name: "index_chapters_on_bible_id_and_book_id_and_number", unique: true
    t.index ["bible_id"], name: "index_chapters_on_bible_id"
    t.index ["book_id"], name: "index_chapters_on_book_id"
  end

  add_foreign_key "books", "bibles", on_delete: :restrict
  add_foreign_key "chapters", "bibles", on_delete: :restrict
  add_foreign_key "chapters", "books", on_delete: :restrict
end
