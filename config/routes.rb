Rails.application.routes.draw do
  post "/evaluate", to: "code#evaluate"

  get "/public_certificate", to: "crypto#public_certificate"
  match "/evaluate", to: "code#cors_preflight", via: [:options]

  get "*path", to: static("index.html")
end
