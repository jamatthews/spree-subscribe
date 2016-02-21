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
      if original_line_item.try(:parts) && original_line_item.part_line_items.present?
        new_line_item = Spree::LineItem.new(original_line_item.attributes.merge({ :id => nil, :updated_at => nil, :created_at => nil , :quantity => params[:line_item][:quantity]})) 
      else
        new_line_item_attributes = original_line_item.attributes.merge({ :id => nil, :updated_at => nil, :created_at => nil}, :quantity => params[:line_item][:quantity])
        new_line_item_attributes[:variant_id] = params[:line_item][:variant_id] if params[:line_item][:variant_id].present?
        new_line_item = Spree::LineItem.new(new_line_item_attributes)
        new_line_item
      end
      new_line_item.order = nil
      new_line_item.order_id = nil
      
      begin
        Spree::LineItem.skip_callback(:create, :after, :update_tax_charge)
        Spree::LineItem.skip_callback(:save, :after, :update_inventory)
        Spree::LineItem.skip_callback(:save, :after, :update_adjustments)
        new_line_item.save(validate: false)
        if original_line_item.try(:parts) && original_line_item.part_line_items.present?
          populate_part_line_items(new_line_item, new_line_item.variant.product.assemblies_parts,  new_line_item.variant.product.assemblies_parts.first.id => params[:line_item][:variant_id])
          new_line_item.save(validate: false)
        end
      ensure
        Spree::LineItem.set_callback(:create, :after, :update_tax_charge)
        Spree::LineItem.set_callback(:save, :after, :update_inventory)
        Spree::LineItem.set_callback(:save, :after, :update_adjustments)
      end
    
      original_line_item.update_column(:subscription_id, nil)
      redirect_to url_for([:edit, :admin, @subscription])
    end
    
    private
    
    def populate_part_line_items(line_item, parts, selected_variants)
      parts.each do |part|
        part_line_item = line_item.part_line_items.find_or_initialize_by(
          line_item: line_item,
          variant_id: variant_id_for(part, selected_variants)
        )
        
        part_line_item.update_attributes!(quantity: part.count)
      end
    end
    
    def variant_id_for(part, selected_variants)
      if part.variant_selection_deferred?
        selected_variants[part.id]
      else
        part.part.id
      end
    end
  end
end