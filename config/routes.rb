Rails.application.routes.draw do
  post "/evaluate", to: "code#evaluate"

  match "/evaluate", to: "code#cors_preflight", via: [:options]

  get "*path", to: static("index.html")
end
