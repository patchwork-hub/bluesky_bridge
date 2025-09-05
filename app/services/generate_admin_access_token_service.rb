class GenerateAdminAccessTokenService
  ACCESS_TOKEN_SCOPES = "read write follow push"

  def initialize(user_id)
    @user_id = user_id
  end

  def call
    access_token = get_or_create_admin_access_token
    access_token&.token || log_error("Failed to generate or retrieve an access token for admin.")
  end

  private

  def get_or_create_admin_access_token
    access_token = Doorkeeper::AccessToken.find_or_create_by(
      resource_owner_id: @user_id,
      application_id: doorkeeper_application.id,
      revoked_at: nil
    ) do |token|
      token.scopes = ACCESS_TOKEN_SCOPES
    end

    access_token
  end

  def doorkeeper_application
    Doorkeeper::Application.first || (return log_error("No Doorkeeper application found."))
  end

  def log_error(message)
    Rails.logger.error("[GenerateAdminAccessTokenService] #{message}")
    nil
  end
end
