module BlueskyBridge::Api::V1
  class UsersController < Api::BaseController
    include Authorization
    before_action :require_user!
    before_action -> { doorkeeper_authorize! :read, :write }
    protect_from_forgery with: :null_session

    def update_is_bluesky_bridge
      user = find_user_by_id
      return render json: { error: 'User not found' }, status: :not_found unless user

      account = user&.account
      return render json: { error: 'Account not found' }, status: :not_found unless account

      # Check if user meets the requirements for Bluesky Bridge
      unless enable_bride_bluesky?(account)
        return render json: { 
          error: 'User does not meet Bluesky Bridge requirements. Must have username, display_name, avatar, and header.' 
        }, status: :unprocessable_entity
      end

      desired_value = parse_boolean_value(params[:is_bluesky_bridge])
      if desired_value.nil?
        return render json: { error: "Missing or invalid 'is_bluesky_bridge' parameter" }, status: :unprocessable_entity
      end

      if user.update(is_bulesky_bridge: desired_value)
        render json: { id: user.id, is_bulesky_bridge: user.is_bulesky_bridge }, status: :ok
      else
        render json: { error: 'Update failed', details: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def find_user_by_id
      ::User.find_by(id: params[:id])
    end

    def parse_boolean_value(value)
      return true if value == true || value == 'true' || value == '1' || value == 1 || value == 'on'
      return false if value == false || value == 'false' || value == '0' || value == 0 || value == 'off'
      nil
    end

    def enable_bride_bluesky?(account)
      account&.username.present? && account&.display_name.present? && 
      account&.avatar.present? && account&.header.present?
    end
  end
end


