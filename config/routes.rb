Rails.application.routes.draw do

  get "/photo/:userID/:filename", to: "common#get_photo"

  #New routes for overhual
  post "/participant", to: "login#create_new_participant"

  #Authentication Routes
  post '/auth/login/participant', to: 'login#login_participant'
  post '/auth/login/coordinator', to: 'login#login_coordinator'

  #Currently logged in participant modification routes
  get '/participant/current', to: 'participant#get_current_participant'
  patch '/participant/current', to: 'participant#update_information'
  patch '/participant/current/password', to: 'participant#update_password'
  post '/participant/current/notes', to: 'participant#create_note'
  post '/participant/current/medication_report', to: 'participant#report_medication'
  post '/participant/current/symptom_report', to: 'participant#report_symptoms'
  post "/photo", to: "participant#add_strip_report"

  #Coordinator only routes
  post "/coordinator", to: "coordinator#post_new_coordinator"
  post '/coordinator/temp_file_link', to: 'coordinator#generate_zip_url'
  get '/coordinator/current', to: 'coordinator#get_current_coordinator'
  patch '/participant/:userID/reset_password', to: 'coordinator#reset_password'
  get '/participant/all', to: 'coordinator#get_records'
  get '/participant/:userID', to: 'coordinator#get_participant'
  post '/resolution', to: 'coordinator#resolve_records' 
  post '/strip_report/:userID/status', to: 'coordinator#set_photo_status'
  get '/strip_zip_file', to: 'temp#generate_zip'

  get '/heatmap', to: 'login#get_heatmap'

end
