Rails.application.config.after_initialize do
  if defined?(Sidekiq) && Sidekiq.respond_to?(:options)
    # Add BlueskyBridge scheduler to existing Sidekiq configuration
    bluesky_scheduler_config = {
      'follow_bluesky_bot_scheduler' => {
        'every' => '10m',
        'class' => 'Scheduler::FollowBlueskyBotScheduler',
        'queue' => 'scheduler'
      }
    }
    
    # Initialize scheduler options if they don't exist
    Sidekiq.options[:scheduler] ||= {}
    Sidekiq.options[:scheduler][:schedule] ||= {}
    
    # Merge our scheduler into the existing schedule
    Sidekiq.options[:scheduler][:schedule].merge!(bluesky_scheduler_config)
    
    Rails.logger.info "BlueskyBridge: Added follow_bluesky_bot_scheduler to run every 10 minutes"
  else
    Rails.logger.warn "BlueskyBridge: Sidekiq not available, scheduler not configured"
  end
end
