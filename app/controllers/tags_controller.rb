class TagsController < ApplicationController

  before_filter :retrieve_repo, :get_tags

  def index
  end

  def show
    @tag = find_tag(params[:id])
  end

  def diff
    @tag_a = find_tag(params[:tag_a])
    @tag_b = find_tag(params[:tag_b])
    @commits = @repo.commits.where("date BETWEEN ? AND ?", @tag_a.commit.committed_date, @tag_b.commit.committed_date).order("date asc")
  end

  private

  def find_tag(tag_name)
    @tags.find{|tag| tag.name == tag_name}
  end

  def get_tags
    @tags = @repo.tags
  end


end
