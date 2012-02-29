class RepoController < ApplicationController

  before_filter :retrieve_repo, :only => [:show, :alerts]

  def index
    @repos = current_user.repos
  end

  def show
    @subscription = current_user.subscriptions.find_by_user_id(current_user.id)
  end

  def alerts
    @alerts = @repo.commits.includes(:alerts).all.flat_map(&:alerts)
    @user_alerts = @repo.commits.includes(:alerts).where("user_id = ?", current_user).flat_map(&:alerts)
  end

  private

  def retrieve_repo
    @repo = current_user.repos.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to repo_url, :alert => "Repo with ID #{params[:id]} could not be found"
  end

end
