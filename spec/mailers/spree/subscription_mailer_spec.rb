require 'spec_helper'
require 'email_spec'

describe Spree::SubscriptionMailer, type: :mailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  
  context "that is ready for reorder" do
    before(:each) do
      @sub = create(:subscription_for_reorder)
      @sub.order.reload
      # DD: calling start will set date into future
      @sub.start
      @sub.update_attribute(:reorder_on, Date.today)
    end
    
    it 'should send a reminder email and update the reminded at date' do
      expect { Spree::SubscriptionMailer.reminder_email(@sub).deliver_now }.to change { Spree::SubscriptionMailer.deliveries.count }.by(1)
      expect(@sub.reminded_at).to_not eq(nil)
    end
  end
end