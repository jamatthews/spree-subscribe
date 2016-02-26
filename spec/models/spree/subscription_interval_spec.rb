require 'spec_helper'

describe Spree::SubscriptionInterval do

  before(:each) do
    @interval = create(:subscription_interval)
  end

  it "has a 3 month time period" do
    expect(@interval.time).to eq(3.months)
  end

  it "have a symbol :month for time_unit_symbol" do
    expect(@interval.time_unit_symbol).to eq(:month)
  end

  it "have a title of '3 Months' for time_title" do
    expect(@interval.time_title).to eq("3 Months")
  end
end
