class SubscriptionController < ApplicationController
  def update
    begin
      subscription = current_user.subscriptions.find(params[:id])
      subscription.update_attributes(params[:subscription])
    rescue ActiveRecord::RecordNotFound
    end
    redirect_to :back
  end
end
