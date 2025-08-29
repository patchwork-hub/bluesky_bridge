# frozen_string_literal: true

class AddDidValueAndIsBlueskyBridgeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :did_value, :string, default: nil, null: true
    add_column :users, :is_bluesky_bridge, :boolean, default: false, null: false
  end
end
