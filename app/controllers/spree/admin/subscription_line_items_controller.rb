if defined? Spree::Admin::ProductsController
class Spree::Admin::SubscriptionLineItemsController < Spree::StoreController
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  helper "spree/subscriptions"

  def destroy
    @subscription = Spree::Subscription.where(:id => params[:subscription_id]).first
    @subscription.line_items.select{|li| li.id = params[:id]}.first.update_column(:subscription_id, nil)
    @subscription.suspend if Spree::LineItem.where(:subscription_id => @subscription.id).count == 0
    redirect_to url_for([:edit, :admin, @subscription])
  end
  
  def update
    @subscription = Spree::Subscription.where(:id => params[:subscription_id]).first
    original_line_item = @subscription.line_items.select{|li| li.id = params[:id]}.first
    new_line_item = Spree::LineItem.new(original_line_item.attributes.merge({ :id => nil , :quantity => params[:line_item][:quantity], :variant_id => params[:line_item][:variant]})) 
    new_line_item.order = nil
    new_line_item.order_id = nil
    
    begin
      Spree::LineItem.skip_callback(:create, :after, :update_tax_charge)
      Spree::LineItem.skip_callback(:save, :after, :update_inventory)
      Spree::LineItem.skip_callback(:save, :after, :update_adjustments)
      new_line_item.save(validate: false)
    ensure
      Spree::LineItem.set_callback(:create, :after, :update_tax_charge)
      Spree::LineItem.set_callback(:save, :after, :update_inventory)
      Spree::LineItem.set_callback(:save, :after, :update_adjustments)
    end
    
    original_line_item.update_column(:subscription_id, nil)
    redirect_to url_for([:edit, :admin, @subscription])
  end
end
end