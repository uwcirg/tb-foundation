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

ActiveRecord::Schema.define(version: 2022_02_01_184931) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "channels", force: :cascade do |t|
    t.bigint "user_id"
    t.string "title", null: false
    t.string "subtitle"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_private", default: false, null: false
    t.integer "messages_count", default: 0, null: false
    t.integer "category", default: 0
    t.bigint "organization_id"
    t.index ["organization_id"], name: "index_channels_on_organization_id"
  end

  create_table "code_applications", force: :cascade do |t|
    t.bigint "photo_code_id"
    t.bigint "photo_review_id"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["photo_code_id", "photo_review_id"], name: "photo_coding_index", unique: true
    t.index ["photo_code_id"], name: "index_code_applications_on_photo_code_id"
    t.index ["photo_review_id"], name: "index_code_applications_on_photo_review_id"
  end

  create_table "contact_tracing_surveys", force: :cascade do |t|
    t.integer "number_of_contacts"
    t.integer "number_of_contacts_tested"
    t.bigint "patient_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["patient_id"], name: "index_contact_tracing_surveys_on_patient_id"
  end

  create_table "contact_tracings", force: :cascade do |t|
    t.bigint "patient_id", null: false
    t.integer "number_of_contacts"
    t.integer "contacts_tested"
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
    t.boolean "doing_okay"
    t.text "doing_okay_reason"
    t.boolean "created_offline", default: false
    t.boolean "was_one_step"
    t.index ["user_id", "date"], name: "index_daily_reports_on_user_id_and_date", unique: true
    t.index ["user_id"], name: "index_daily_reports_on_user_id"
  end

  create_table "education_message_statuses", force: :cascade do |t|
    t.integer "treatment_day", null: false
    t.boolean "was_helpful"
    t.bigint "patient_id"
    t.index ["patient_id", "treatment_day"], name: "patient_treatment_day_index", unique: true
    t.index ["patient_id"], name: "index_education_message_statuses_on_patient_id"
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
    t.date "date"
    t.index ["daily_report_id"], name: "index_medication_reports_on_daily_report_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "channel_id"
    t.bigint "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "photo_path"
    t.boolean "is_hidden", default: false
  end

  create_table "messaging_notifications", force: :cascade do |t|
    t.bigint "channel_id"
    t.bigint "user_id"
    t.bigint "last_message_id"
    t.integer "read_message_count", default: 0, null: false
    t.boolean "is_subscribed", default: true, null: false
    t.index ["channel_id", "user_id"], name: "index_messaging_notifications_on_channel_id_and_user_id", unique: true
  end

  create_table "milestones", force: :cascade do |t|
    t.datetime "datetime"
    t.bigint "user_id"
    t.boolean "all_day"
    t.string "location"
    t.string "title"
    t.index ["user_id"], name: "index_milestones_on_user_id"
  end

  create_table "notificaiton_status", force: :cascade do |t|
    t.datetime "time_delivered"
    t.datetime "time_interacted"
    t.bigint "daily_notification_id"
    t.index ["daily_notification_id"], name: "index_notificaiton_status_on_daily_notification_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "title", null: false
    t.index ["title"], name: "index_organizations_on_title", unique: true
  end

  create_table "patient_informations", force: :cascade do |t|
    t.datetime "datetime_patient_added"
    t.datetime "datetime_patient_activated"
    t.integer "reminders_since_last_report", default: 0
    t.bigint "patient_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "adherent_days", default: 0
    t.integer "adherent_photo_days", default: 0
    t.integer "number_of_photo_requests", default: 1
    t.datetime "requests_updated_at", default: "2021-06-02 15:20:46"
    t.boolean "had_symptom_in_past_week", default: false
    t.boolean "had_severe_symptom_in_past_week", default: false
    t.boolean "negative_photo_in_past_week", default: false
    t.integer "number_of_conclusive_photos", default: 0
    t.integer "medication_streak", default: 0
    t.integer "days_reported_not_taking_medication", default: 0
    t.integer "treatment_outcome"
    t.datetime "datetime_patient_archived"
    t.date "app_end_date"
    t.index ["patient_id"], name: "index_patient_informations_on_patient_id", unique: true
  end

  create_table "patient_notes", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "patient_id", null: false
    t.string "title", null: false
    t.text "note", null: false
    t.bigint "practitioner_id", null: false
    t.index ["patient_id"], name: "index_patient_notes_on_patient_id"
    t.index ["practitioner_id"], name: "index_patient_notes_on_practitioner_id"
  end

  create_table "photo_code_groups", force: :cascade do |t|
    t.integer "group_code"
    t.string "group"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["group_code"], name: "index_photo_code_groups_on_group_code", unique: true
  end

  create_table "photo_codes", force: :cascade do |t|
    t.bigint "photo_code_group_id"
    t.integer "sub_group_code"
    t.string "title"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["photo_code_group_id", "sub_group_code"], name: "photo_coding_definitions_index", unique: true
    t.index ["photo_code_group_id"], name: "index_photo_codes_on_photo_code_group_id"
  end

  create_table "photo_days", force: :cascade do |t|
    t.date "date", null: false
    t.bigint "patient_id"
    t.index ["patient_id", "date"], name: "index_photo_days_on_patient_id_and_date", unique: true
    t.index ["patient_id"], name: "index_photo_days_on_patient_id"
  end

  create_table "photo_reports", force: :cascade do |t|
    t.bigint "daily_report_id"
    t.string "photo_url"
    t.boolean "approved"
    t.datetime "approval_timestamp"
    t.bigint "user_id", null: false
    t.bigint "practitioner_id"
    t.date "date"
    t.boolean "photo_was_skipped", default: false
    t.text "why_photo_was_skipped"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.boolean "back_submission", default: false
    t.index ["daily_report_id"], name: "index_photo_reports_on_daily_report_id"
    t.index ["practitioner_id"], name: "index_photo_reports_on_practitioner_id"
  end

  create_table "photo_review_colors", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "photo_reviews", force: :cascade do |t|
    t.bigint "bio_engineer_id"
    t.bigint "photo_report_id"
    t.bigint "test_strip_version_id"
    t.integer "test_line_review", default: 0
    t.integer "control_line_review", default: 0
    t.bigint "control_color_id"
    t.bigint "test_color_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "test_color_value"
    t.string "control_color_value"
    t.index ["bio_engineer_id"], name: "index_photo_reviews_on_bio_engineer_id"
    t.index ["control_color_id"], name: "index_photo_reviews_on_control_color_id"
    t.index ["photo_report_id"], name: "index_photo_reviews_on_photo_report_id"
    t.index ["test_color_id"], name: "index_photo_reviews_on_test_color_id"
    t.index ["test_strip_version_id"], name: "index_photo_reviews_on_test_strip_version_id"
  end

  create_table "push_notification_statuses", force: :cascade do |t|
    t.bigint "user_id"
    t.boolean "sent_successfully", default: false
    t.boolean "delivered_successfully", default: false
    t.boolean "clicked", default: false
    t.datetime "clicked_at"
    t.datetime "delivered_at"
    t.integer "notification_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_push_notification_statuses_on_user_id"
  end

  create_table "reminders", force: :cascade do |t|
    t.datetime "datetime", null: false
    t.integer "category", null: false
    t.bigint "patient_id"
    t.boolean "send_push", default: true
    t.string "other_category"
    t.text "note"
    t.index ["patient_id"], name: "index_reminders_on_patient_id"
  end

  create_table "resolutions", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "note"
    t.integer "kind", null: false
    t.bigint "practitioner_id"
    t.bigint "patient_id"
    t.datetime "resolved_at"
    t.index ["practitioner_id", "patient_id", "kind"], name: "index_resolutions_on_practitioner_id_and_patient_id_and_kind"
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
    t.date "date"
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

  create_table "test_strip_versions", force: :cascade do |t|
    t.integer "version"
    t.text "description"
    t.text "id_range_description"
    t.date "shipment_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["version"], name: "index_test_strip_versions_on_version", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "password_digest", null: false
    t.boolean "active", default: true, null: false
    t.string "family_name", null: false
    t.string "given_name", null: false
    t.string "push_url"
    t.string "push_auth"
    t.string "push_p256dh"
    t.integer "type", default: 0, null: false
    t.string "email"
    t.string "phone_number"
    t.datetime "treatment_start"
    t.string "username"
    t.string "medication_schedule"
    t.integer "status", default: 1, null: false
    t.bigint "organization_id", default: 1, null: false
    t.integer "gender"
    t.integer "age"
    t.integer "locale", default: 1
    t.datetime "app_start"
    t.string "gender_other"
    t.boolean "has_temp_password", default: false
    t.date "treatment_end_date"
    t.string "push_client_permission"
    t.datetime "push_subscription_updated_at"
    t.string "time_zone", default: "America/Argentina/Buenos_Aires"
    t.index ["organization_id"], name: "index_users_on_organization_id"
  end

  add_foreign_key "channels", "organizations"
  add_foreign_key "channels", "users"
  add_foreign_key "contact_tracing_surveys", "users", column: "patient_id"
  add_foreign_key "education_message_statuses", "users", column: "patient_id"
  add_foreign_key "messages", "channels"
  add_foreign_key "messaging_notifications", "channels"
  add_foreign_key "messaging_notifications", "messages", column: "last_message_id"
  add_foreign_key "messaging_notifications", "users"
  add_foreign_key "patient_informations", "users", column: "patient_id"
  add_foreign_key "patient_notes", "users", column: "patient_id"
  add_foreign_key "patient_notes", "users", column: "practitioner_id"
  add_foreign_key "photo_days", "users", column: "patient_id"
  add_foreign_key "photo_reports", "users", column: "practitioner_id"
  add_foreign_key "photo_reviews", "photo_review_colors", column: "control_color_id"
  add_foreign_key "photo_reviews", "photo_review_colors", column: "test_color_id"
  add_foreign_key "photo_reviews", "users", column: "bio_engineer_id"
  add_foreign_key "reminders", "users", column: "patient_id"
  add_foreign_key "temp_accounts", "organizations", column: "organization", primary_key: "title"
  add_foreign_key "temp_accounts", "users", column: "practitioner_id"
end
