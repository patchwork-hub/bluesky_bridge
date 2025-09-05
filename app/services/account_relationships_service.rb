# frozen_string_literal: true
require 'ostruct'
require_dependency Rails.root.join(
  'app/serializers/rest/account_relationship_severance_event_serializer'
).to_s

class AccountRelationshipsService < BaseService
  def call(admin_account, target_account_id)
    @admin_account = admin_account
    account_relationships(target_account_id)
  end

  private

  def account_relationships(target_account_id)
    target_account = Account.find_by(id: target_account_id)
    return [] unless target_account

    # This directly uses Mastodon's internal presenter
    relationships_presenter = AccountRelationshipsPresenter.new(
      [target_account], # Array of target accounts
      @admin_account.id, # ID of the "current" account
      with_suspended: true
    )

    # Extract the relationships data from the presenter
    relationships_hash = relationships_presenter.instance_variable_get(:@relationships) || {}

    # Convert each hash into an OpenStruct so the serializer can call methods like .id
    records = relationships_hash.values.map { |h| OpenStruct.new(h) }

    # Serialize each record individually and return the array
    records.map do |record|
      ActiveModelSerializers::SerializableResource.new(
        record,
        serializer: REST::AccountRelationshipSeveranceEventSerializer
      ).as_json
    end
  end
end
