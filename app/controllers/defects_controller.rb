class DefectsController < ApplicationController

  before_filter :retrieve_repo

  def index
    @pivotal_defects = @repo.pivotal_defects
    @zendesk_defects = @repo.zendesk_defects
  end

end
