class AddNotifyOnAnalysisToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :notify_on_analysis, :boolean, :default => false
  end
end
