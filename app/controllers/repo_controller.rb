class RepoController < ApplicationController

  def index
    @repos = current_user.repos
  end

  def show
    @repo = current_user.repos.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to repo_url, :alert => "Repo with ID #{params[:id]} could not be found"
  end

end
