# frozen_string_literal: true

class AddDidValueAndBlueskyBridgeEnabledToUsers < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!
  
  def change
    safety_assured do
      add_column :users, :did_value, :string, default: nil, null: true
      add_column :users, :bluesky_bridge_enabled, :boolean, default: false, null: false
    end
  end
end
