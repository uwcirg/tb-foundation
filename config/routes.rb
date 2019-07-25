Rails.application.routes.draw do
  post "/evaluate", to: "code#evaluate"

  post "/coordinator", to: "code#post_new_coordinator"

  post "/photo", to: "code#add_strip_report"

  get "/photo/:userID/:filename", to: "code#get_photo"

  get "/testingnew", :to => redirect('/test.html')

  get "/all_meds", to: "code#get_all_strip_reports"

  get "/public_certificate", to: "crypto#public_certificate"

  match "/evaluate", to: "code#cors_preflight", via: [:options]
  
  match "/photo", to: "code#cors_preflight", via: [:options]

  get "*path", to: static("index.html")
end
