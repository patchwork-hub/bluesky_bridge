module BlueskyBridge::Api::V1
  class UsersController < Api::BaseController
    include Authorization
    before_action :require_authenticated_user!

    def update_bluesky_bridge_setting
      user = current_user
      account = user.account
      return render json: { error: 'Account not found' }, status: :not_found unless account

      # Check if user meets the requirements for Bluesky Bridge
      unless meets_bluesky_bridge_requirements?(account)
        return render json: { 
          error: 'User does not meet Bluesky Bridge requirements. Must have username, display_name, avatar, and header.' 
        }, status: :unprocessable_entity
      end

      # Validate parameter presence first
      unless params.key?(:bluesky_bridge_enabled)
        return render json: { error: "Missing 'bluesky_bridge_enabled' parameter" }, status: :bad_request
      end

      desired_value = parse_boolean_param(params[:bluesky_bridge_enabled])

      if user.update(bluesky_bridge_enabled: desired_value)
        render json: { id: user.id, bluesky_bridge_enabled: user.bluesky_bridge_enabled }, status: :ok
      else
        render json: { error: 'Update failed', details: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def parse_boolean_param(value)
      ActiveModel::Type::Boolean.new.cast(value)
    end

    def meets_bluesky_bridge_requirements?(account)
      account&.username.present? && account&.display_name.present? && 
      account&.avatar.present? && account&.header.present?
    end
  end
end


