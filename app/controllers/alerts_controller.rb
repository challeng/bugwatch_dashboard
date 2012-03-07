class AlertsController < ApplicationController

  before_filter :retrieve_repo

  def index
    @alerts = @repo.alerts.all
    @user_alerts = @repo.alerts.where("commits.user_id" => current_user).all
  end

  def show
    @alert = @repo.alerts.find(params[:id])
    @related_bug_fixes = @repo.bug_fixes.where("file = ? AND klass = ? AND function = ?",
                                      @alert.file, @alert.klass, @alert.function)
  rescue ActiveRecord::RecordNotFound
    redirect_to repo_alerts_path(@repo), :alert => "Alert with ID #{params[:id]} could not be found"
  end

  private

  def retrieve_repo
    @repo = current_user.repos.find(params[:repo_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to repos_path, :alert => "Repo with ID #{params[:repo_id]} could not be found"
  end

end
