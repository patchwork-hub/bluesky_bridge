module BlueskyBridge::Api::V1
  class UsersController < Api::BaseController
    include Authorization
    before_action :require_user!
    before_action -> { doorkeeper_authorize! :read, :write }
    protect_from_forgery with: :null_session

    def update_is_bluesky_bridge
      user = current_user
      return render json: { error: 'User not found' }, status: :not_found unless user

      account = user&.account
      return render json: { error: 'Account not found' }, status: :not_found unless account

      # Check if user meets the requirements for Bluesky Bridge
      unless enable_bride_bluesky?(account)
        return render json: { 
          error: 'User does not meet Bluesky Bridge requirements. Must have username, display_name, avatar, and header.' 
        }, status: :unprocessable_entity
      end

      desired_value = truthy_param?(params[:is_bluesky_bridge])
      if desired_value.nil?
        return render json: { error: "Missing or invalid 'is_bluesky_bridge' parameter" }, status: :unprocessable_entity
      end

      if user.update(is_bluesky_bridge: desired_value)
        render json: { id: user.id, is_bluesky_bridge: user.is_bluesky_bridge }, status: :ok
      else
        render json: { error: 'Update failed', details: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def truthy_param?(key)
      ActiveModel::Type::Boolean.new.cast(key)
    end

    def enable_bride_bluesky?(account)
      true
      # account&.username.present? && account&.display_name.present? && 
      # account&.avatar.present? && account&.header.present?
    end
  end
end


