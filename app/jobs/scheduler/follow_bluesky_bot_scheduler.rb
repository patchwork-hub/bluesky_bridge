module Scheduler

  class FollowBlueskyBotScheduler
    include Sidekiq::Worker
    sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 15.minutes.to_i, queue: :scheduler

    def perform
      # Only execute if Bluesky Bridge is enabled via environment variable
      return unless ENV['IS_BLUESKY_BRIDGE_ENABLED'].present? && ENV['IS_BLUESKY_BRIDGE_ENABLED'] == 'true'

      users = User.where(did_value: nil, bluesky_bridge_enabled: true)
      return unless users.any?

      users.each do |user|

        account = user&.account
        next if account.nil?

        token = fetch_oauth_token(user)
        next if token.nil?

        target_account_id = Rails.cache.fetch('bluesky_bridge_bot_account_id', expires_in: 24.hours) do
          search_target_account_id(token, account)
        end
        target_account = Account.find_by(id: target_account_id)
        next if target_account.nil?

        account_relationship_array = handle_relationship(account, target_account.id)
        next unless account_relationship_array.present? && account_relationship_array&.last

        if account_relationship_array&.last['requested']
          UnfollowService.new.call(account, target_account)
        end
        
        next if bluesky_bridge_enabled?(account)

        if account_relationship_array&.last['following'] == true && account_relationship_array&.last['requested'] == false
          process_did_value(user, token, account)
        else
          FollowService.new.call(account, target_account)
          account_relationship_array = handle_relationship(account, target_account.id)
          process_did_value(user, token, account) if account_relationship_array.present? && account_relationship_array&.last && account_relationship_array&.last['following']
        end
      end
    end

    private

    def bluesky_bridge_enabled?(account)
      account&.username.present? && account&.display_name.present? && 
      account&.avatar.present? && account&.header.present?
    end

    def search_target_account_id(token, account)
      query = '@bsky.brid.gy@bsky.brid.gy'
      retries = 5
      result = nil

      while retries >= 0
        result = ContributorSearchService.new(query, account: account, token: token).call
        if result.any?
          return result.last['id']
        end
        retries -= 1
      end
      nil
    end

    def fetch_oauth_token(user)
      GenerateAdminAccessTokenService.new(user&.id).call
    end

    def process_did_value(user, token, account)
      did_value = FetchDidValueService.new.call(account, user)

      if did_value
        begin
          create_dns_record(did_value, account)
          sleep 1.minutes
          create_direct_message(token, account)
          community.update!(did_value: did_value)
        rescue StandardError => e
          Rails.logger.error("Error processing did_value for community #{community.id}: #{e.message}")
        end
      end
    end

    def create_dns_record(did_value, account)
      route53 = Aws::Route53::Client.new
      hosted_zones = route53.list_hosted_zones

      env = ENV.fetch('RAILS_ENV', nil)
      channel_zone = case env
      when 'staging'
        hosted_zones.hosted_zones.find { |zone| zone.name ==  ENV['LOCAL_DOMAIN'] }
      when 'production'
        hosted_zones.hosted_zones.find { |zone| zone.name ==  ENV['LOCAL_DOMAIN'] }
      else
        hosted_zones.hosted_zones.find { |zone| zone.name == 'localhost:3000.' }
      end

      if channel_zone
        name = "_atproto.#{account&.username}.#{ENV['LOCAL_DOMAIN']}"
        route53.change_resource_record_sets({
          hosted_zone_id:  channel_zone.id, # Hosted Zone for channel.org
          change_batch: {
            changes: [
              {
          action: 'UPSERT',
          resource_record_set: {
            name: name,
            type: 'TXT',
            ttl: 60,
            resource_records: [
              { value: "\"did=#{did_value}\"" },
            ],
          },
              },
            ],
          },
        })
      else
        Rails.logger.error("Hosted zone for #{ENV.fetch('RAILS_ENV', nil)} not found.")
      end
    end

    def create_direct_message(token, account)

      name = "#{account&.username}@#{ENV['LOCAL_DOMAIN']}"

      status_params = {
        "in_reply_to_id": nil,
        "language": "en",
        "media_ids": [],
        "poll": nil,
        "sensitive": false,
        "spoiler_text": "",
        "status": "@bsky.brid.gy@bsky.brid.gy username #{name}",
        "visibility": "direct"
      }

      PostStatusService.new.call(token: token, options: status_params)
    end

    def handle_relationship(account, target_account_id)
      AccountRelationshipsService.new.call(account, target_account_id)
    end

  end
end