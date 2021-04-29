# Rails Routing Helpers

## Keeping plurals only for index / create methods

This allows you to have both GET /channels and /channel/:id go to the same controller

```
    resources :channels, only: [:index, :create]

    resources :channel, only: [:show], controller: "channels" do
      resources :messages, only: [:index, :create]
    end

```

## Scary Bug - Uninitalized Constant YourModel

Using the module: option to create a folder of controllers seemed like a good idea at one point. I found it to make rails auto importing / namespacing break if the folder name matches a Model name. I tried to fix this by adding a require for the model at the top, and that seemed to break the whole server due to a circular import error. Reverting to a previous commit and restarting the server via docker were able to fix this.