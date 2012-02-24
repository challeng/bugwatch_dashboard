class ApplicationController < ActionController::Base
  protect_from_forgery

  include AuthenticationHelper

  before_filter :enforce_authentication

  def index
    render :text => "TODO"
  end
end
