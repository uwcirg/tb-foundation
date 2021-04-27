# Rails Routing Helpers

## Keeping plurals only for index / create methods

This allows you to have both GET /channels and /channel/:id go to the same controller

```
    resources :channels, only: [:index, :create]

    resources :channel, only: [:show], controller: "channels" do
      resources :messages, only: [:index, :create]
    end

```