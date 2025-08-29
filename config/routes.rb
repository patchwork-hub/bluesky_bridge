BlueskyBridge::Engine.routes.draw do
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      # POST /api/v1/users/bluesky_bridge?is_bluesky_bridge=true
      post 'users/bluesky_bridge', to: 'users#update_is_bluesky_bridge'
    end
  end
end
