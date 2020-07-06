Rails.application.routes.draw do

  #Notifications
  post '/push', to: 'login#send_push_to_user'
  get '/push_key', to: 'user#push_key'
  patch '/update_user_subscription', to: 'user#update_user_subscription'
  post '/notify_all', to: 'practitioner#send_notifcation_all'

  #post '/message', to: 'message#post_message'
  post '/channel', to: 'channel#new_channel'
  get '/channels', to: 'channel#all_channels'
  post '/channel/:channelID/messages', to: 'channel#post_message'
  get '/channel/:channelID/messages', to: 'channel#get_recent_messages'
  get '/channel/:channelID/messages/:messageID', to: 'channel#get_messages_before'
  get '/messages/unread', to: 'channel#get_unread_message_numbers'

  #Testing new data model
  get '/patient/me', to: 'patient#get_patient'
  get '/practitioner/me', to: 'practitioner#get_current_practitioner'
  post '/authentication', to: 'user#authenticate'

  post '/patient/self/activate', to: 'patient#activate_patient'

  #Routes from in progress refractoring
  post '/auth', to: 'user#login'
  delete '/auth', to: 'user#logout'

  post '/practitioner', to: 'administrator#create_practitioner'

  post '/administrator', to:'practitioner#create_admin'
  post '/patient', to: 'practitioner#generate_temp_patient'

  #Image Recognition Pipeline
  #post '/lab_image_test', to: 'practitioner#upload_lab_test'
  #get '/lab_test/all', to: 'practitioner#get_all_tests'

  get '/patient/daily_reports/photo_upload_url', to: 'patient#generate_upload_url'
  get '/organizations', to: 'user#get_all_organizations'

  #List of patients for practitioner
  get '/practitioner/patients', to: 'practitioner#get_patients'
  get '/practitioner/patient/:patient_id', to: 'practitioner#get_patient'
  get '/practitioner/temporary_patients', to: 'practitioner#get_temp_accounts'

  #Medication Reports
  post '/daily_report', to: 'patient#post_daily_report'
  get '/daily_reports', to: 'patient#get_patient_reports'

  #Notification Reminder
  patch '/patient/reminder', to: 'patient#update_notification_time'


  #New Ones
  get '/patients/photo_reports', to: 'practitioner#get_photos'
  get '/patients/photo_reports/processed', to: 'practitioner#get_historical_photos'
  get '/patient/:patient_id/reports', to: 'practitioner#get_patient_reports'
  patch '/photo_submission/:photo_id', to: 'practitioner#audit_photo'
  post '/patient/:patientID/milestones', to: 'milestone#create'
  get '/patient/me/milestones', to: 'patient#get_milestones'
  get '/patients/severe', to: 'practitioner#patients_with_symptoms'
  get '/patients/missed', to: 'practitioner#patients_missed_reporting'
  get '/test/patients', to: 'practitioner#patients_with_adherence'

  get '/patient/:patient_id/symptoms', to: 'practitioner#patient_symptom_summary'
  get '/patients/reports/recent', to: 'practitioner#recent_reports'

  post '/patient/:patient_id/resolutions', to: 'practitioner#create_resolution'
  patch '/patient/:patient_id/activation_code', to: 'practitioner#reset_temp_password'

  post '/patient/self/password', to: 'patient#change_inital_password'






end
