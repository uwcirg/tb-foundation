Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs" unless Rails.env.production?
  mount Rswag::Api::Engine => "/api-docs" unless Rails.env.production?

  # In progress, implementing a stable API
  namespace "v2" do
    resource :vapid_public_key, only: [:show]
    resources :time_summary, only: [:index]
    resources :daily_report, only: [:index, :create]
    resources :medication_reports, only: [:create]
    resources :symptom_reports, only: [:create]
    resources :photo_reports, only: [:create, :index, :update, :show]
    resources :mood_reports, only: [:create]
    resources :resolutions, only: [:create]
    resources :reminders, only: [:destroy]

    resources :patient, only: [:update, :show] do
      resources :daily_reports, only: [:index], controller: "daily_report"
      resources :photo_reports, only: [:index]
      resources :activation, only: [:create]
      resources :contact_tracing_surveys, only: [:index, :create]
      resources :treatment_outcome, only: [:create]
      resources :reminders, only: [:index, :create]
      resource :test_medication_reminder, only: [:create], controller: "test_medication_reminder"
    end

    resources :patients, only: [:index], controller: "patient"
    resources :patient_issues, only: [:index]
    resources :patient_basics, only: [:index]

    resources :user, only: [:index] do
      resource :push_subscription, only: [:update]
    end

    resources :trial_summary, only: [:index]
    resources :organizations, only: [:index]

    resources :channels, only: [:index, :create]
    resources :message, only: [:update], controller: "messages"

    resources :channel, only: [:show], controller: "channels" do
      resources :messages, only: [:index, :create]
    end

    resources :push_notification_status, only: [:update]
    resources :photo_upload_urls, only: [:create]

    resources :photo_codes, only: [:create, :index]
    resources :photo_reviews, only: [:create, :index, :update]
    resource :photo_review_stats, only: [:show]

    get "/heatmap", to: "trial_summary#get_heatmap"
  end

  # --------------------------------------------------------------------------------------------------------------------------------------
  #Routes below were developed over time and standarization / organization is lacking
  #Over time converting these to stable and better organized "V2" routes

  #Notifications
  get "/push_key", to: "user#push_key"
  patch "/update_user_subscription", to: "user#update_user_subscription"

  get "/patient/me", to: "patient#get_patient"
  get "/practitioner/me", to: "practitioner#get_current_practitioner"
  post "/authentication", to: "user#authenticate"
  patch "/user/me/password", to: "user#update_password"

  post "/patient/self/activate", to: "patient#activate_patient"

  #Routes from in progress refractoring
  post "/auth", to: "user#login"
  delete "/auth", to: "user#logout"
  delete "/auth/cookie", to: "user#delete_cookie"

  get "/patient/daily_reports/photo_upload_url", to: "patient#generate_upload_url"

  #List of patients for practitioner
  get "/practitioner/patients", to: "practitioner#get_patients"
  get "/practitioner/patient/:patient_id", to: "practitioner#get_patient"
  get "/practitioner/temporary_patients", to: "practitioner#get_temp_accounts"
  get "/practitioner/resolutions/summary", to: "practitioner#tasks_completed_today"

  #Medication Reports
  post "/daily_report", to: "patient#post_daily_report"
  get "/daily_reports", to: "patient#get_patient_reports"

  #Notification Reminder
  patch "/patient/reminder", to: "patient#update_notification_time"

  #Practitioner Facing Patient Routes
  get "/patients/photo_reports", to: "practitioner#get_photos"
  get "/patients/photo_reports/processed", to: "practitioner#get_historical_photos"
  get "/patient/:patient_id/reports", to: "practitioner#get_patient_reports"
  patch "/photo_submission/:photo_id", to: "practitioner#audit_photo"
  get "/patients/severe", to: "practitioner#patients_with_symptoms"
  get "/patients/missed", to: "practitioner#patients_missed_reporting"
  get "/patients/need_support", to: "practitioner#patients_need_support"
  get "/patients/missed-photo", to: "practitioner#patients_who_missed_photo"

  get "/patient/:patient_id/symptoms", to: "practitioner#patient_unresolved_symptoms"
  get "/patient/:patient_id/symptom_summary", to: "practitioner#patient_symptom_summary"
  get "/patient/:patient_id/missed_reports", to: "practitioner#patient_missed_days"
  get "/patients/reports/recent", to: "practitioner#recent_reports"

  post "/patient/:patient_id/resolutions", to: "practitioner#create_resolution"
  patch "/patient/:patient_id/activation_code", to: "practitioner#reset_temp_password"

  post "/patient/self/password", to: "patient#change_inital_password"

  #i18n
  get "/config/locales", to: "application#get_locales"

  get "/user/current", to: "user#get_current_user"

  resources :channels, only: [:index, :create], module: "channel" do
    resources :messages, only: [:index, :create]
  end

  resources :message, only: [:update]

  get "/unread_messages", to: "channel/unread_messages#index"

  get "/patient/:patient_id/json_reports", to: "practitioner#transfer_patient_data"

  resources :patient, only: [] do
    scope module: :patient do
      resources :notes, only: [:index, :create, :update]
      resources :reminders, only: [:index, :create, :destroy]
      resources :education_statuses, only: [:create, :index]
      resources :password_reset, only: [:create], :path => "/password-reset"
    end
  end

  resources :patients, only: [:create], controller: "patient/patients"

  get "/photo_uploaders/messaging", to: "photo_upload#message_upload_url"
  get "/health-check", to: "health_check#index"
end
