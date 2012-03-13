class ReposController < ApplicationController

  before_filter :retrieve_repo, :only => [:show, :commit]

  def index
    @repos = current_user.repos
  end

  def show
    @subscription = current_user.subscriptions.find_by_repo_id(@repo.id)
    @commits = @repo.commits.order("id DESC").limit(20)
    @hot_spots = @repo.hot_spots
  end

  def commit
    @commit = @repo.commits.find_by_sha!(params[:sha])
    @commit_scores = @commit.accumulated_commit_scores
  rescue ActiveRecord::RecordNotFound
    redirect_to repo_path(@repo), :alert => "Commit with sha #{params[:sha]} could not be found for #{@repo.name}"
  end

  private

  def retrieve_repo
    @repo = current_user.repos.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to repos_path, :alert => "Repo with ID #{params[:id]} could not be found"
  end

end
