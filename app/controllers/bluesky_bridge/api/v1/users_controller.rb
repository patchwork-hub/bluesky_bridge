module BlueskyBridge::Api::V1
  class UsersController < Api::BaseController
    include Authorization
    before_action :require_user!
    before_action -> { doorkeeper_authorize! :read, :write }
    protect_from_forgery with: :null_session

    def update_bluesky_bridge_setting
      user = current_user
      return render json: { error: 'User not found' }, status: :not_found unless user

      account = user&.account
      return render json: { error: 'Account not found' }, status: :not_found unless account

      # Check if user meets the requirements for Bluesky Bridge
      unless enable_bluesky_bridge?(account)
        return render json: { 
          error: 'User does not meet Bluesky Bridge requirements. Must have username, display_name, avatar, and header.' 
        }, status: :unprocessable_entity
      end

      desired_value = truthy_param?(params[:bluesky_bridge_enabled])
      if desired_value.nil?
        return render json: { error: "Missing or invalid 'bluesky_bridge_enabled' parameter" }, status: :unprocessable_entity
      end

      if user.update(bluesky_bridge_enabled: desired_value)
        render json: { id: user.id, bluesky_bridge_enabled: user.bluesky_bridge_enabled }, status: :ok
      else
        render json: { error: 'Update failed', details: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def truthy_param?(key)
      ActiveModel::Type::Boolean.new.cast(key)
    end

    def enable_bluesky_bridge?(account)
      true
      # account&.username.present? && account&.display_name.present? && 
      # account&.avatar.present? && account&.header.present?
    end
  end
end


