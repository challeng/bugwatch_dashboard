class RepoController < ApplicationController

  def index
    @repos = current_user.repos
  end

  def show
    @repo = current_user.repos.find(params[:id])
    @subscription = current_user.subscriptions.find_by_user_id(current_user.id)
  rescue ActiveRecord::RecordNotFound
    redirect_to repo_url, :alert => "Repo with ID #{params[:id]} could not be found"
  end

end
