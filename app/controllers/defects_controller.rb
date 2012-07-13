class DefectsController < ApplicationController

  before_filter :retrieve_repo

  def index
    @pivotal_defects = @repo.pivotal_defects
    @zendesk_defects = @repo.zendesk_defects
    @releases = @repo.releases.production.order("deploy_date ASC").limit(10)
  end

end
