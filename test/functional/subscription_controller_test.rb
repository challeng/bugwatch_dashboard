require 'test_helper'

class SubscriptionControllerTest < ActionController::TestCase

  def setup
    logged_in!
    request.env['HTTP_REFERER'] = "redirect url"
  end

  def subscription
    subscriptions(:test_subscription)
  end

  test "POST#update redirects back" do
    post :update, :id => subscription.id
    assert_redirected_to "redirect url"
  end

  test "POST#update updates subscription" do
    assert_false subscription.notify_on_analysis
    post :update, :id => subscription.id, :subscription => {:notify_on_analysis => true}
    assert_true subscription.reload.notify_on_analysis
  end

  test "POST#update does not update if subscription does not belong to user" do
    new_subscription = Subscription.create!(:repo => repos(:test_repo))
    assert_false new_subscription.notify_on_analysis
    post :update, :id => new_subscription.id, :subscription => {:notify_on_analysis => true}
    assert_false new_subscription.reload.notify_on_analysis
  end

  test "POST#update does not update if subscription not found" do
    Subscription.expects(:update_attributes).never
    post :update, :id => 999, :subscription => {:notify_on_analysis => true}
  end

end
