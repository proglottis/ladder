module Api::V1
class AuthController < ApiController

  def google
    access_token_uri = URI('https://accounts.google.com/o/oauth2/token')
    people_api_uri = URI('https://www.googleapis.com/plus/v1/people/me/openIdConnect')

    access_token_response = Net::HTTP.post_form(access_token_uri, {
      code: params['code'],
      client_id: params['clientId'],
      client_secret: Rails.application.secrets.google_secret,
      redirect_uri: params['redirectUri'],
      grant_type: 'authorization_code'
    })
    token = JSON.parse(access_token_response.body)

    profile_request = Net::HTTP::Get.new(people_api_uri)
    profile_request['Authorization'] = "#{token['token_type']} #{token['access_token']}"
    profile_response = Net::HTTP.start(people_api_uri.hostname, people_api_uri.port, use_ssl: people_api_uri.scheme == 'https') do |http|
      http.request(profile_request)
    end
    profile = JSON.parse(profile_response.body)

    service = Service.find_by(provider: 'google_oauth2', uid: profile['sub'])

    if service.blank?
      render json: {message: "Unauthorized"}, status: :unauthorized
      return
    end
    render json: {token: service.user.generate_token}
  end

end
end
