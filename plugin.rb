# name: Jirengu login
# about: Jirengu login
# version: 0.9.9
# author: Erick Guan
# url: https://meta.discoursecn.org/localization-pack#迁移至-05-版本

require 'omniauth-oauth2'

class OmniAuth::Strategies::Jirengu < OmniAuth::Strategies::OAuth2
  option :client_options, {
    :site => 'http://user.jirengu.com',
    :authorize_url => '/oauth/authorize',
    :token_url => '/oauth/token'
  }

  uid do
    raw_info['id'].to_s
  end

  info do
    {
      'nickname' => raw_info['name'],
      'name' => raw_info['real_name'],
      'image' => raw_info['avatar'],
      'email' => raw_info['email'],
      'gender' => raw_info['gender'],
      'birthday' => raw_info['bitrhday'],
      'school' => raw_info['school'],
      'location' => raw_info['location'],
      'company' => raw_info['company'],
      'bio' => raw_info['bio']
    }
  end

  extra do
    {
      :raw_info => raw_info
    }
  end

  def raw_info
    access_token.options[:mode] = :query
    @raw_info ||= access_token.get("/api/v1/me.json").parsed
  end

  def email
    raw_info['email']
  end

  def authorize_params
    super.tap do |params|
      %w[scope client_options].each do |v|
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
    email = auth_token[:email]
    raw_info = auth_token[:extra][:raw_info]
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
