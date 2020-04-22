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

ActiveRecord::Schema.define(version: 2020_04_22_140341) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "channels", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.string "subtitle"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_private", default: false, null: false
  end

  create_table "daily_notifications", force: :cascade do |t|
    t.boolean "active"
    t.time "time"
    t.bigint "user_id"
    t.index ["user_id"], name: "index_daily_notifications_on_user_id"
  end

  create_table "daily_reports", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "date"
    t.index ["user_id"], name: "index_daily_reports_on_user_id"
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
    t.bigint "daily_report_id"
    t.datetime "datetime_taken"
    t.boolean "medication_was_taken"
    t.text "why_medication_not_taken"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.index ["daily_report_id"], name: "index_medication_reports_on_daily_report_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "channel_id"
    t.bigint "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "notificaiton_status", force: :cascade do |t|
    t.datetime "time_delivered"
    t.datetime "time_interacted"
    t.bigint "daily_notification_id"
    t.index ["daily_notification_id"], name: "index_notificaiton_status_on_daily_notification_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "channel_id"
    t.bigint "user_id"
    t.bigint "last_message_id"
    t.boolean "push_subscription"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "title", null: false
    t.index ["title"], name: "index_organizations_on_title", unique: true
  end

  create_table "photo_reports", force: :cascade do |t|
    t.bigint "daily_report_id"
    t.datetime "captured_at"
    t.string "photo_url"
    t.boolean "approved"
    t.datetime "approval_timestamp"
    t.bigint "user_id", null: false
    t.index ["daily_report_id"], name: "index_photo_reports_on_daily_report_id"
  end

  create_table "symptom_reports", force: :cascade do |t|
    t.bigint "daily_report_id"
    t.datetime "time_medication_taken"
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
    t.boolean "headache"
    t.boolean "dizziness"
    t.integer "nausea_rating"
    t.text "other"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.index ["daily_report_id"], name: "index_symptom_reports_on_daily_report_id"
  end

  create_table "temp_accounts", force: :cascade do |t|
    t.bigint "phone_number", null: false
    t.string "given_name", null: false
    t.string "family_name", null: false
    t.date "treatment_start"
    t.string "code_digest", null: false
    t.string "organization", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "practitioner_id"
    t.boolean "activated", default: false
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
    t.datetime "treatment_start"
    t.string "username"
    t.bigint "practitioner_id"
    t.string "medication_schedule"
    t.index ["practitioner_id"], name: "index_users_on_practitioner_id"
  end

  add_foreign_key "channels", "users"
  add_foreign_key "messages", "channels"
  add_foreign_key "notifications", "channels"
  add_foreign_key "notifications", "messages", column: "last_message_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "temp_accounts", "organizations", column: "organization", primary_key: "title"
  add_foreign_key "temp_accounts", "users", column: "practitioner_id"
  add_foreign_key "users", "users", column: "practitioner_id"
end
