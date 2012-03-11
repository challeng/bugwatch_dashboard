module ApplicationHelper

  def nav_repo_class(repo)
    "active" if @repo && @repo.name == repo.name
  end

  def nav_action_class(url_options)
    "active" if current_page?(url_options)
  end

end
