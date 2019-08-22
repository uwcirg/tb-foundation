Rails.application.routes.draw do
  post "/evaluate", to: "code#evaluate"

  post "/coordinator", to: "code#post_new_coordinator"

  post "/photo", to: "code#add_strip_report"

  get "/photo/:userID/:filename", to: "code#get_photo"

  get "/public_certificate", to: "crypto#public_certificate"

  #match "/evaluate", to: "code#cors_preflight", via: [:options]
  
  #match "/photo", to: "code#cors_preflight", via: [:options]

  get "*path", to: static("index.html")

  #New routes for overhual
  post "/participant", to: "participant#create_new_participant"
  #match "/participant", to: "participant#set_cors_headers", via: [:options]

  #Authentication Routes
  post '/auth/login/participant', to: 'auth#login_participant'
  post '/auth/login/coordinator', to: 'auth#login_coordinator'
  #match '/auth/login', to: "code#cors_preflight", via: [:options]

end
