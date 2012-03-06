require 'test_helper'
require 'rack/openid'

class SessionsControllerTest < ActionController::TestCase

  attr_reader :email, :first_name, :last_name, :identifier_url

  def openid
    @openid ||= stub(:status => :success, :display_identifier => identifier_url)
  end

  def user
    @user ||= User.new
  end

  def setup
    @email = 'email@address'
    @first_name = 'first_name'
    @last_name = 'last_name'
    @identifier_url = 'identifier_url'
    attribute_exchange = stub
    attribute_exchange.stubs(:get_single).with('http://axschema.org/contact/email').returns(email)
    attribute_exchange.stubs(:get_single).with('http://axschema.org/namePerson/first').returns(first_name)
    attribute_exchange.stubs(:get_single).with('http://axschema.org/namePerson/last').returns(last_name)
    OpenID::AX::FetchResponse.stubs(:from_success_response).with(openid).returns(attribute_exchange)
    request.env[Rack::OpenID::RESPONSE] = openid
  end

  test "POST#create creates user if doesn't exist on success" do
    user.id = 5
    User.stubs(:find_by_email).with(email).returns(nil)
    User.expects(:create!).
        with(:identifier_url => identifier_url, :email => email, :name => "#{first_name} #{last_name}").
        returns(user)
    post :create
    assert_equal user.id, session[:user_id]
  end

  test "POST#create updates identifier_url if user exists" do
    user.id = 6
    User.stubs(:find_by_email).with(email).returns(user)
    user.expects(:update_attribute).with(:identifier_url, identifier_url)
    post :create
    assert_equal user.id, session[:user_id]
  end

  test "POST#create redirects to root if successful" do
    post :create
    assert_redirected_to root_path
  end

  test "POST#create displays error if failure" do
    openid.stubs(:status).returns(:failure)
    post :create
    assert_equal "problem", response.body
  end

  test "POST#create redirects to new session if not through openid" do
    request.env[Rack::OpenID::RESPONSE] = nil
    post :create
    assert_redirected_to new_sessions_path
  end

  test "GET#new sends authenticate header" do
    required = %w(http://axschema.org/contact/email http://axschema.org/namePerson/first http://axschema.org/namePerson/last)
    authenticate_params = {:identifier => "https://www.google.com/accounts/o8/id", :required => required,
                            :return_to => sessions_url, :method => 'POST'}
    expected = Rack::OpenID.build_header(authenticate_params)
    get :new
    assert_equal expected, response.headers['WWW-Authenticate']
  end

  test "GET#new sends unauthenticated http status code" do
    get :new
    assert_equal 401, response.status
  end

end
