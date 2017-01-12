require 'omniauth-oauth2'

class OmniAuth::Strategies::Jirengu < OmniAuth::Strategies::OAuth2
  option :client_options, {
                          :site           => "https://user.jirengu.com",
                          :authorize_url  => "/oauth2/authorize",
                          :token_url      => "/oauth2/access_token"
                        }
  option :token_params, {
                        :parse          => :json
                      }

  uid do
    raw_info['id']
  end

  info do
    {
      :nickname     => raw_info['screen_name'],
      :name         => raw_info['name'],
      :location     => raw_info['location'],
      :image        => find_image,
      :description  => raw_info['description'],
    }
  end

  extra do
    {
      :raw_info => raw_info
    }
  end

  def raw_info
    access_token.options[:mode] = :query
    access_token.options[:param_name] = 'access_token'
    @uid ||= access_token.get('/api/v1/me.json').parsed["uid"]
    @raw_info ||= access_token.get("/api/v1/me.json", :params => {:uid => @uid}).parsed
  end

  def find_image
    raw_info[%w(avatar_hd avatar_large profile_image_url).find { |e| raw_info[e].present? }]
  end

  ##
  # You can pass +display+, +with_offical_account+ or +state+ params to the auth request, if
  # you need to set them dynamically. You can also set these options
  # in the OmniAuth config :authorize_params option.
  #
  #
  def authorize_params
    super.tap do |params|
      %w[display with_offical_account forcelogin].each do |v|
        if request.params[v]
          params[v.to_sym] = request.params[v]
        end
      end
    end
  end

end

OmniAuth.config.add_camelization "jirengu", "Jirengu"

# Discourse plugin
class JirenguAuthenticator < ::Auth::Authenticator

  def name
    'jirengu'
  end

  def after_authenticate(auth_token)
    result = Auth::Result.new

    data = auth_token[:info]
    email = auth_token[:extra][:email]
    raw_info = auth_token[:extra][:raw_info].slice(%i[screen_name verified])
    jirengu_uid = auth_token[:uid]

    current_info = ::PluginStore.get('jirengu', "jirengu_uid_#{jirengu_uid}")

    result.user =
      if current_info
        User.where(id: current_info[:user_id]).first
      end

    result.name = data['name']
    result.username = data['nickname']
    result.email = email
    result.extra_data = { jirengu_uid: jirengu_uid, raw_info: raw_info }

    result
  end

  def after_create_account(user, auth)
    jirengu_uid = auth[:extra_data][:uid]
    ::PluginStore.set('jirengu', "jirengu_uid_#{jirengu_uid}", {user_id: user.id})
  end

  def register_middleware(omniauth)
    omniauth.provider :jirengu, :setup => lambda { |env|
      strategy = env['omniauth.strategy']
      strategy.options[:client_id] = SiteSetting.jirengu_client_id
      strategy.options[:client_secret] = SiteSetting.jirengu_client_secret
    }
  end
end

auth_provider :frame_width => 920,
              :frame_height => 800,
              :authenticator => JirenguAuthenticator.new,
              :background_color => 'rgb(230, 22, 45)'

register_css <<CSS

.btn-social.jirengu:before {
}

CSS
