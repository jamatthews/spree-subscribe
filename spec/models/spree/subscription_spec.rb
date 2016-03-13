require 'spec_helper'

describe Spree::Subscription do
  context "validation" do
    it "cannot make multiple subscriptions per orderXinterval"
    it "has many line items"
  end


  context "that is in 'cart' state" do
    before(:each) do
      @sub = create(:subscription)
      @sub.order.reload
    end

    it "should have no reorder date" do
      expect(@sub.line_items.first).to be
      expect(@sub.state).to eq("cart")
      expect(@sub.reorder_on).to be_nil
    end

    it "should have reorder date that is three months (i.e. subscription interval) from today on activation" do
      @sub.start
      expect(@sub.reorder_on).to eq(Date.today + 3.month)
    end

    it "should have a billing address on activation" do
      expect(@sub.order.bill_address).to be
      expect(@sub.billing_address).to be_nil
      @sub.start
      expect(@sub.billing_address).to be
    end

    it "should have a shipping address on activation" do
      expect(@sub.order.shipping_address).to be
      expect(@sub.shipping_address).to be_nil
      @sub.start
      expect(@sub.shipping_address).to be
    end

    it "should have a payment method on activation" do
      expect(@sub.payment_method).to be_nil
      @sub.start
      expect(@sub.payment_method).to be
    end

    it "should have a payment source on activation" do
      expect(@sub.source).to be_nil
      @sub.start
      expect(@sub.source).to be
    end

    it "should have a user on activation" do
      expect(@sub.user).to be_nil
      @sub.start
      expect(@sub.user).to be
    end
  end

  context "that is ready for reorder" do
    before(:each) do
      @sub = create(:subscription_for_reorder)
      @sub.order.reload
      # DD: calling start will set date into future
      @sub.start
      @sub.update_attribute(:reorder_on,Date.today)
    end

    it "should have reorder_on reset" do
      expect(@sub.reorder_on).to eq(Date.today)
      expect(@sub.reorder).to be_truthy
      expect(@sub.reorder_on).to eq(Date.today + 3.month)
    end

    it "should have a valid order" do
      expect(@sub.reorder).to be_truthy
      expect(@sub.reorders.count).to eq(1)
    end

    it "should have a valid order with a billing address" do
      expect(@sub.create_reorder).to be_truthy
      order = @sub.reorders.first
      expect(order.bill_address).to eq(@sub.billing_address)  # DD: uses == operator override in Spree::Address
      expect(order.bill_address.id).not_to eq @sub.billing_address.id # DD: not the same database record
    end

    it "should have a valid order with a shipping address" do
      expect(@sub.create_reorder).to be_truthy
      order = @sub.reorders.first
      expect(order.ship_address).to eq(@sub.shipping_address)  # DD: uses == operator override in Spree::Address
      expect(order.ship_address.id).not_to eq @sub.shipping_address.id # DD: not the same database record
    end

    it "should have a valid line item" do
      @sub.create_reorder
      expect(@sub.add_subscribed_line_items).to be_truthy
      order = @sub.reorders.first
      expect(order.line_items.count).to eq(1)
    end

    it "should have a valid order with a shipping method" do
      @sub.create_reorder
      @sub.add_subscribed_line_items
      expect(@sub.select_shipping).to be_truthy

      order = @sub.reorders.first
      expect(order.shipments.count).to eq(1)

      s = order.shipments.first
      expect(s.shipping_method.code).to eq @sub.shipping_method.code
    end

    it "should have a valid order with a payment method" do
      @sub.create_reorder
      @sub.add_subscribed_line_items
      @sub.select_shipping
      expect(@sub.add_payment).to be_truthy

      order = @sub.reorders.first
      expect(order.payments.count).to eq(1)

      payment = order.payments.first
      expect(payment.payment_method).to eq @sub.payment_method  # DD: should be same database record
    end

    it "should have a valid order with a payment source" do
      @sub.create_reorder
      @sub.add_subscribed_line_items
      @sub.select_shipping
      expect(@sub.add_payment).to be_truthy

      order = @sub.reorders.first
      expect(order.payments.count).to be(1)
      expect(order.payments.first.source).to eq @sub.source  # DD: should be same database record
    end

    it "should have a payment" do
      @sub.create_reorder
      @sub.add_subscribed_line_items
      @sub.select_shipping
      expect(@sub.add_payment).to be_truthy

      order = @sub.reorders.first
      expect(order.payments).to be
    end

    it "should have a completed order" do
      expect(@sub.reorder).to be_truthy

      order = @sub.reorders.first
      expect(order.state).to eq("complete")
      expect(order.completed?).to be
    end
    
    context "with a promotion" do
      before(:each) do
        @sub = create(:subscription_for_reorder_with_promotion)
        @sub.order.reload
        # DD: calling start will set date into future
        @sub.start
        @sub.update_attribute(:reorder_on,Date.today)
      end
      
      it "should have a promotion applied" do
        @sub.create_reorder
        @sub.add_subscribed_line_items
        @sub.select_shipping
        expect(@sub.apply_promotions).to be_truthy
        
        order = @sub.reorders.first
        expect(order.promotions.count).to be(1)
        expect(order.adjustment_total).to eq(-10)
      end
    end
    
    it 'should appear in due_within' do
      expect(Spree::Subscription.due_within(7.days).count).to eq(1)
    end
  end
  
  context "that has just been reordered" do
    before(:each) do
      @sub = create(:subscription_for_reorder)
      @sub.order.reload
      # DD: calling start will set date into future
      @sub.start
      @sub.update_attribute(:reorder_on, Date.today + 4.weeks)
    end
    
    it 'should appear in due_within' do
      expect(Spree::Subscription.due_within(7.days).count).to eq(0)
    end
  end
end
