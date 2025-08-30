# frozen_string_literal: true

class AddDidValueAndBlueskyBridgeEnabledToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :did_value, :string, default: nil, null: true
    add_column :users, :bluesky_bridge_enabled, :boolean, default: false, null: false
  end
end
