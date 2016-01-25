require 'rails_helper'

RSpec.describe "order_addresses/index", :type => :view do
  before(:each) do
    assign(:order_addresses, [
      OrderAddress.create!(
        :order_id => 1,
        :name => "Name",
        :mobile => "Mobile",
        :address => "Address",
        :zip_code => "Zip Code"
      ),
      OrderAddress.create!(
        :order_id => 1,
        :name => "Name",
        :mobile => "Mobile",
        :address => "Address",
        :zip_code => "Zip Code"
      )
    ])
  end

  it "renders a list of order_addresses" do
    render
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Mobile".to_s, :count => 2
    assert_select "tr>td", :text => "Address".to_s, :count => 2
    assert_select "tr>td", :text => "Zip Code".to_s, :count => 2
  end
end
