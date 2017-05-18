class GoogleAuthenticator
  ACCESS_TOKEN_URI = URI('https://accounts.google.com/o/oauth2/token')
  PEOPLE_API_URI = URI('https://www.googleapis.com/plus/v1/people/me/openIdConnect')

  def fetch_profile(code, redirect_uri:, client_id: nil)
    access_token_response = Net::HTTP.post_form(ACCESS_TOKEN_URI, {
      code: code,
      client_id: client_id || Rails.application.secrets.google_key,
      client_secret: Rails.application.secrets.google_secret,
      redirect_uri: redirect_uri,
      grant_type: 'authorization_code'
    })
    token = JSON.parse(access_token_response.body)

    profile_request = Net::HTTP::Get.new(PEOPLE_API_URI)
    profile_request['Authorization'] = "#{token['token_type']} #{token['access_token']}"
    profile_response = Net::HTTP.start(PEOPLE_API_URI.hostname, PEOPLE_API_URI.port, use_ssl: PEOPLE_API_URI.scheme == 'https') do |http|
      http.request(profile_request)
    end
    JSON.parse(profile_response.body)
  end
end
