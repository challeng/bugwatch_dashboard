class TagsController < ApplicationController

  before_filter :retrieve_repo, :get_tags

  def index
  end

  def show
    @tag = get_tag(params[:id])
  end

  def diff
    @tag_a = get_tag(params[:tag_a])
    @tag_b = get_tag(params[:tag_b])
    @commits = Commit.where("date BETWEEN ? AND ?", @tag_a.commit.committed_date, @tag_b.commit.committed_date)
  end

  private

  def get_tag(tag_name)
    @tags.find{|tag| tag.name == tag_name}
  end

  def get_tags
    @tags = @repo.tags
  end

  def retrieve_repo
    @repo = current_user.repos.find(params[:repo_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to repos_path, :alert => "Repo with ID #{params[:repo_id]} could not be found"
  end


end
