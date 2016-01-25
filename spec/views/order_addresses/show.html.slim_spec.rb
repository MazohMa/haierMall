require 'rails_helper'

RSpec.describe "order_addresses/show", :type => :view do
  before(:each) do
    @order_address = assign(:order_address, OrderAddress.create!(
      :order_id => 1,
      :name => "Name",
      :mobile => "Mobile",
      :address => "Address",
      :zip_code => "Zip Code"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Mobile/)
    expect(rendered).to match(/Address/)
    expect(rendered).to match(/Zip Code/)
  end
end
