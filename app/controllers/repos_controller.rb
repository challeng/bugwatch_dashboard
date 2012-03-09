class ReposController < ApplicationController

  before_filter :retrieve_repo, :only => [:show]

  def index
    @repos = current_user.repos
  end

  def show
    @subscription = current_user.subscriptions.find_by_user_id(current_user.id)
    @commits = @repo.commits.order("id DESC").limit(20)
  end

  private

  def retrieve_repo
    @repo = current_user.repos.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to repos_path, :alert => "Repo with ID #{params[:id]} could not be found"
  end

end
