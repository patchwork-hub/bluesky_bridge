module BlueskyBridge
  class Engine < ::Rails::Engine
    isolate_namespace BlueskyBridge

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    initializer 'bluesky_bridge.load_routes' do |app|
      app.routes.prepend do
        mount BlueskyBridge::Engine => "/", :as => :bluesky_bridge
      end
    end
  end
end
