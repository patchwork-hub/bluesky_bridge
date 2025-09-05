BlueskyBridge::Engine.routes.draw do
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      post 'users/bluesky_bridge', to: 'users#update_bluesky_bridge_setting'
    end
  end
end
