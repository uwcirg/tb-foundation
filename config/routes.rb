Rails.application.routes.draw do
  post "/evaluate", to: "code#evaluate"

  post "/coordinator", to: "code#post_new_coordinator"

  post "/photo", to: "code#add_strip_report"

  get "/photo/:userID/:filename", to: "code#get_photo"

  get "/public_certificate", to: "crypto#public_certificate"

  get "*path", to: static("index.html")

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

  #Coordinator only routes
  patch '/participant/:userID/reset_password', to: 'coordinator#reset_password'

end
