class ReposController < ApplicationController

  layout false, :only => [:fixcache_graph]

  before_filter :retrieve_repo, :only => [:show, :commit, :file, :subscription, :fixcache_graph]

  def index
    @repos = current_user.repos
  end

  def show
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

  def subscription
    @subscription = current_user.subscriptions.find_by_repo_id(@repo.id)
  end

  def fixcache_graph
    @repo_presenter = RepoPresenter.new(@repo)
  end

  private

  def retrieve_repo
    @repo = current_user.repos.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to repos_path, :alert => "Repo with ID #{params[:id]} could not be found"
  end

end
