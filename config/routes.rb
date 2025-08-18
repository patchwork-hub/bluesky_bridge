BlueskyBridge::Engine.routes.draw do
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :users, only: [] do
        member do
          # PATCH /api/v1/users/:id/bluesky_bridge
          patch :bluesky_bridge, action: :update_is_bluesky_bridge
        end
      end
    end
  end
end
