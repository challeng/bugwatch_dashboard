class SessionController < ApplicationController

  ATTRIBUTE_EXCHANGE = {
      :email => "http://axschema.org/contact/email",
      :first_name => "http://axschema.org/namePerson/first",
      :last_name => "http://axschema.org/namePerson/last",
  }

  skip_before_filter :verify_authenticity_token, :enforce_authentication

  def new
    response.headers['WWW-Authenticate'] = Rack::OpenID.build_header(
        :identifier => "https://www.google.com/accounts/o8/id",
        :required => [ATTRIBUTE_EXCHANGE[:email],
                      ATTRIBUTE_EXCHANGE[:first_name],
                      ATTRIBUTE_EXCHANGE[:last_name]],
        :return_to => session_url,
        :method => 'POST')
    head 401
  end

  def create
    if openid = request.env[Rack::OpenID::RESPONSE]
      case openid.status
      when :success
        ax = OpenID::AX::FetchResponse.from_success_response(openid)
        user = find_or_create_user(ax, openid.display_identifier)
        session[:user_id] = user.id
        redirect_to(root_path)
      when :failure
        render :text => 'problem'
      end
    else
      redirect_to new_session_path
    end
  end

  private

  def find_or_create_user(ax, identifier_url)
    email = ax.get_single(ATTRIBUTE_EXCHANGE[:email])
    name = [ax.get_single(ATTRIBUTE_EXCHANGE[:first_name]),
            ax.get_single(ATTRIBUTE_EXCHANGE[:last_name])].join(" ")
    existing_user = User.find_by_email(email)
    if existing_user
      existing_user.update_attribute(:identifier_url, identifier_url)
      existing_user
    else
      User.create!(:identifier_url => identifier_url, :email => email, :name => name)
    end
  end

end
