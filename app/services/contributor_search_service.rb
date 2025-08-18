# frozen_string_literal: true

class ContributorSearchService
  def initialize(query, options = {})
    @query = query
    # @api_base_url = options[:url]
    @token = options[:token]
    @account = options[:account]
  end

  def call
    results = search_mastodon
    accounts = results[:accounts]
    find_saved_accounts(accounts)
  end

  private

  def search_mastodon
    # Use Mastodon's internal SearchService
    SearchService.new.call(
      @query,
      @account, # current_account
      11, # limit
      resolve: true
    )
  end

  def find_saved_accounts(accounts)
    return [] unless accounts.present?

    accounts.map do |account|
      {
        'id' => account.id.to_s,
        'username' => account.username,
        'display_name' => account.display_name,
        'domain' => account.domain,
        'note' => account.note,
        'avatar_url' => account.avatar.url,
        'profile_url' => account.url,
        'following' => following_status(account),
        'is_muted' => is_muted(account),
        'is_own_account' => account.id == @account_id
      }
    end
  end

  def following_status(account)
    follow_ids = Follow.where(account_id: @account_id).pluck(:target_account_id)
    follow_request_ids = FollowRequest.where(account_id: @account_id).pluck(:target_account_id)

    if follow_ids.include?(account.id)
      'following'
    elsif follow_request_ids.include?(account.id)
      'requested'
    else
      'not_followed'
    end
  end

  def is_muted(account)
    Mute.where(account_id: @account_id, target_account_id: account.id).exists?
  end
end
