class ReposController < ApplicationController

  before_filter :retrieve_repo, :only => [:show, :commit, :file]

  def index
    @repos = current_user.repos
  end

  def show
    @subscription = current_user.subscriptions.find_by_repo_id(@repo.id)
    @commits = @repo.commits.order("date DESC").limit(50).reverse
    @repo_presenter = RepoPresenter.new(@repo)
  end

  def commit
    @commit = @repo.commits.find_by_sha!(params[:sha])
  rescue ActiveRecord::RecordNotFound
    redirect_to repo_path(@repo), :alert => "Commit with sha #{params[:sha]} could not be found for #{@repo.name}"
  end

  def file
    @filename = "#{params[:filename]}.rb"
    @related_bug_fixes = @repo.bug_fixes.where("file = ?", @filename)
  end

  private

  def retrieve_repo
    @repo = current_user.repos.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to repos_path, :alert => "Repo with ID #{params[:id]} could not be found"
  end

end
