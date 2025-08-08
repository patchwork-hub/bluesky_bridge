Rails.application.routes.draw do
  mount BlueskyBridge::Engine => "/bluesky_bridge"
end
