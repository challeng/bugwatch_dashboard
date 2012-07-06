class ApplicationController < ActionController::Base
  protect_from_forgery

  include AuthenticationHelper

  before_filter :enforce_authentication

  def retrieve_repo
    @repo = current_user.repos.find(params[:repo_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to repos_path, :alert => "Repo with ID #{params[:repo_id]} could not be found"
  end

end
