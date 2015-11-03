if defined? Spree::Admin::ProductsController
  class Spree::Admin::SubscriptionsController < Spree::Admin::ResourceController
    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    before_action :load_subscription, except: :index

    helper "spree/subscriptions"

    def index
      @subscriptions = Spree::Subscription.where(state: [:active, :inactive]).
        page(params[:page]).
        per(params[:per_page] || Spree::Config[:orders_per_page])
    end

    def destroy
      @subscription.active? ? @subscription.suspend : @subscription.resume

      redirect_to account_url
    end

    private

    def load_subscription
      @subscription = Spree::Subscription.find_by_id! params[:id]
      authorize! action, @subscription
    end

  end
end