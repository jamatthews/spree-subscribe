require 'spec_helper'

describe Spree::SubscriptionsController, type: :controller do
  
  let(:user) { stub_model(Spree::LegacyUser) }
  let(:subscription) { FactoryGirl.create(:subscription_for_reorder) }
  let(:order) { FactoryGirl.create(:order_with_totals) }
  
  before do
    
    controller.should_receive(:try_spree_current_user).at_least(:once).and_return(user)
    controller.should_receive(:spree_current_user).and_return(user)
    user.should_receive(:subscriptions).and_return([subscription])
    controller.should_receive(:current_order).at_least(:once).and_return(order)
  end
  
  context '#index' do
     it 'should load the user and subscriptions' do
        spree_get :index
        expect(response).to be_success
        expect(assigns(:subscriptions)).to eq([subscription])
     end
  end
  
  context '#destroy' do
    it 'should pause the subscription' do
      subscription = subscription
      controller.class.skip_before_filter :load_subscription
      spree_post :destroy, id: subscription.id
      expect(response).to redirect_to(subscriptions_path)
    end
  end

end