require 'rails_helper'

RSpec.describe "order_addresses/new", :type => :view do
  before(:each) do
    assign(:order_address, OrderAddress.new(
      :order_id => 1,
      :name => "MyString",
      :mobile => "MyString",
      :address => "MyString",
      :zip_code => "MyString"
    ))
  end

  it "renders new order_address form" do
    render

    assert_select "form[action=?][method=?]", order_addresses_path, "post" do

      assert_select "input#order_address_order_id[name=?]", "order_address[order_id]"

      assert_select "input#order_address_name[name=?]", "order_address[name]"

      assert_select "input#order_address_mobile[name=?]", "order_address[mobile]"

      assert_select "input#order_address_address[name=?]", "order_address[address]"

      assert_select "input#order_address_zip_code[name=?]", "order_address[zip_code]"
    end
  end
end
