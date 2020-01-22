# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_01_16_183449) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "channels", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.string "subtitle"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "coordinators", primary_key: "uuid", id: :string, force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uuid"], name: "index_coordinators_on_uuid"
  end

  create_table "lab_tests", force: :cascade do |t|
    t.bigint "test_id"
    t.string "description", null: false
    t.string "photo_url", null: false
    t.boolean "is_positive", null: false
    t.boolean "test_was_run", null: false
    t.bigint "minutes_since_test", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "medication_reports", force: :cascade do |t|
    t.string "participant_id", null: false
    t.datetime "timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "took_medication", default: false, null: false
    t.string "not_taking_medication_reason"
    t.string "resolution_uuid"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "channel_id"
    t.bigint "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "notes", force: :cascade do |t|
    t.string "author_type", null: false
    t.text "title"
    t.text "text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "author_id", null: false
    t.index ["author_type", "author_id"], name: "index_notes_on_author_type_and_author_id"
  end

  create_table "participants", primary_key: "uuid", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.date "treatment_start", null: false
    t.string "phone_number", null: false
    t.string "password_digest", null: false
    t.string "push_url"
    t.string "push_auth"
    t.string "push_p256dh"
    t.index ["uuid"], name: "index_participants_on_uuid"
  end

  create_table "resolutions", primary_key: "uuid", id: :string, force: :cascade do |t|
    t.string "author_type", null: false
    t.string "author_id", null: false
    t.datetime "timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "note"
    t.string "participant_uuid"
    t.string "status"
    t.index ["uuid"], name: "index_resolutions_on_uuid"
  end

  create_table "strip_reports", force: :cascade do |t|
    t.string "participant_id", null: false
    t.datetime "timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.text "photo", null: false
    t.string "resolution_uuid"
    t.string "url_photo"
  end

  create_table "symptom_reports", force: :cascade do |t|
    t.string "participant_id", null: false
    t.datetime "timestamp"
    t.boolean "nausea"
    t.boolean "redness"
    t.boolean "hives"
    t.boolean "fever"
    t.boolean "appetite_loss"
    t.boolean "blurred_vision"
    t.boolean "sore_belly"
    t.boolean "yellow_coloration"
    t.boolean "difficulty_breathing"
    t.boolean "facial_swelling"
    t.text "other"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "nausea_rating"
    t.string "resolution_uuid"
    t.boolean "headache"
    t.boolean "dizziness"
  end

  create_table "users", force: :cascade do |t|
    t.string "password_digest", null: false
    t.boolean "active", default: true, null: false
    t.string "family_name", null: false
    t.string "given_name", null: false
    t.string "managing_organization", null: false
    t.integer "language", default: 0, null: false
    t.string "push_url"
    t.string "push_auth"
    t.string "push_p256dh"
    t.integer "type", default: 0, null: false
    t.string "email"
    t.string "phone_number"
    t.string "general_practitioner"
    t.datetime "treatment_start"
  end

  add_foreign_key "channels", "users"
  add_foreign_key "medication_reports", "participants", primary_key: "uuid"
  add_foreign_key "messages", "channels"
  add_foreign_key "strip_reports", "participants", primary_key: "uuid"
  add_foreign_key "symptom_reports", "participants", primary_key: "uuid"
end
