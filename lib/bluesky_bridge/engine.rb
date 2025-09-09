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

    # Configure BlueskyBridge scheduler when the server starts (not during precompilation)
    initializer 'bluesky_bridge.configure_scheduler', after: :load_config_initializers do |app|
      app.config.after_initialize do
        # Only run when we're actually starting the server, not during rake tasks or precompilation
        if defined?(Sidekiq)
          Sidekiq.configure_server do |config|
            bluesky_scheduler_config = {
              'follow_bluesky_bot_scheduler' => {
                'every' => '10m',
                'class' => 'Scheduler::FollowBlueskyBotScheduler',
                'queue' => 'scheduler'
              }
            }
            
            config[:scheduler] ||= {}
            config[:scheduler][:schedule] ||= {}
            config[:scheduler][:schedule].merge!(bluesky_scheduler_config)
            Rails.logger.info "BlueskyBridge: Added follow_bluesky_bot_scheduler to run every 10 minutes in engine.rb"
          end
        end
      end
    end
  end
end
