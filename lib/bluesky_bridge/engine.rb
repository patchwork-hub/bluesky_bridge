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

    # Load Sidekiq scheduler
    initializer "bluesky_bridge.sidekiq_scheduler" do |_app|
      if defined?(Sidekiq) && defined?(Sidekiq::Scheduler)
        Sidekiq.schedule ||= {}
        Sidekiq.schedule['follow_bluesky_bot_scheduler'] = {
          'every' => ['10m'],
          'class' => 'Scheduler::FollowBlueskyBotScheduler',
          'queue' => 'scheduler'
        }
        Sidekiq::Scheduler.reload_schedule!
      end
    end
  end
end
