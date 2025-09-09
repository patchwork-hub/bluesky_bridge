Rails.application.config.after_initialize do
  if defined?(Sidekiq) && Sidekiq.respond_to?(:configure_server)
    # Add BlueskyBridge scheduler to existing Sidekiq configuration
    bluesky_scheduler_config = {
      'follow_bluesky_bot_scheduler' => {
        'every' => '10m',
        'class' => 'Scheduler::FollowBlueskyBotScheduler',
        'queue' => 'scheduler'
      }
    }
    
    # Use the new Sidekiq configuration API
    Sidekiq.configure_server do |config|
      config[:scheduler] ||= {}
      config[:scheduler][:schedule] ||= {}
      
      # Merge our scheduler into the existing schedule
      config[:scheduler][:schedule].merge!(bluesky_scheduler_config)
    end
  else
    Rails.logger.warn "BlueskyBridge: Sidekiq not available, scheduler not configured"
  end
end
