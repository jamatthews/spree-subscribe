class Spree::SubscriptionsController < Spree::StoreController
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  helper "spree/subscriptions"
  before_action :load_subscription, only: [:update, :destroy]
  before_filter :authenticate_spree_user!
  
  
  def destroy
    @subscription.active? ? @subscription.suspend : @subscription.resume
    redirect_to subscriptions_path
  end
  
  def index
    @user = spree_current_user
    @subscriptions = @user.subscriptions
  end
  
  def update
    @subscription.reorder_on = params[:subscription][:reorder_on]
    @subscription.subscription_interval = Spree::SubscriptionInterval.find(params[:subscription][:interval])
    @subscription.save!
    redirect_to subscriptions_path
  end
  
  private
  def load_subscription
    @subscription = Spree::Subscription.where(:id => params[:id], :user_id => spree_current_user.id).first
  end

  def subscription_params
    params.permit(subscription: [:reorder_on, :interval])
  end
end
