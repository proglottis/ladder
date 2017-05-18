require 'net/http'

module Api::V1
class AuthController < ApiController

  def google
    authenticator = GoogleAuthenticator.new
    profile = authenticator.fetch_profile(
      params['code'],
      client_id: params['clientId'],
      redirect_uri: params['redirectUri']
    )
    service = Service.find_by(provider: 'google_oauth2', uid: profile['sub'])

    if service.blank?
      render json: {message: "Unauthorized"}, status: :unauthorized
      return
    end
    render json: {token: service.user.generate_token}
  end

end
end
