Rails.application.routes.draw do
    #Notifications
    post "/push", to: "login#send_push_to_user"
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

    #New Ones
    get "/patients/photo_reports", to: "practitioner#get_photos"
    get "/patients/photo_reports/processed", to: "practitioner#get_historical_photos"
    get "/patient/:patient_id/reports", to: "practitioner#get_patient_reports"
    patch "/photo_submission/:photo_id", to: "practitioner#audit_photo"
    post "/patient/:patientID/milestones", to: "milestone#create"
    get "/patient/me/milestones", to: "patient#get_milestones"
    get "/patients/severe", to: "practitioner#patients_with_symptoms"
    get "/patients/missed", to: "practitioner#patients_missed_reporting"
    get "/patients/need_support", to: "practitioner#patients_need_support"
    get "/test/patients", to: "practitioner#patients_with_adherence"

    get "/patient/:patient_id/symptoms", to: "practitioner#patient_unresolved_symptoms"
    get "/patient/:patient_id/symptom_summary", to: "practitioner#patient_symptom_summary"
    get "/patient/:patient_id/missed_reports", to: "practitioner#patient_missed_days"
    get "/patients/reports/recent", to: "practitioner#recent_reports"

    post "/patient/:patient_id/resolutions", to: "practitioner#create_resolution"
    patch "/patient/:patient_id/activation_code", to: "practitioner#reset_temp_password"

    post "/patient/self/password", to: "patient#change_inital_password"

    #i18n
    get "/config/locales", to: "application#get_locales"
    #post '/patient/me/education_status', to: 'patient#mark_educational_message_viewed'

    get "/user/current", to: "user#get_current_user"

    scope "/organizations/:organization_id", module: "organization" do
      resources :cohort_summary, only: :index
      resources :patients, only: [:index, :create, :show]
    end

    resources :channels, only: [:index, :create], module: "channel" do
      resources :messages, only: [:index, :create]
    end

    resources :message, only: [:update]

    resources :photo_reports, only: [:index], controller: "photo_report"

    get "/unread_messages", to: "channel/unread_messages#index"

    resources :patient, only: [] do
      scope module: :patient do
        resources :notes, only: [:index, :create, :update]
        resources :reminders, only: [:index, :create, :destroy]
        resources :education_statuses, only: [:create, :index]
      end
    end

    resources :trial_summary, only: [:index], :path => "/trial-summary"

    resources :patients, only: [:create], controller: "patient/patients"
    resources :practitioners, only: [:index], controller: "practitioner/practitioners"
    resources :organizations, only: [:index, :create, :show], controller: "organization/organizations"

    get "/photo_uploaders/messaging", to: "photo_upload#message_upload_url"
end
