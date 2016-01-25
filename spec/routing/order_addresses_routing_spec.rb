require "rails_helper"

RSpec.describe OrderAddressesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/order_addresses").to route_to("order_addresses#index")
    end

    it "routes to #new" do
      expect(:get => "/order_addresses/new").to route_to("order_addresses#new")
    end

    it "routes to #show" do
      expect(:get => "/order_addresses/1").to route_to("order_addresses#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/order_addresses/1/edit").to route_to("order_addresses#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/order_addresses").to route_to("order_addresses#create")
    end

    it "routes to #update" do
      expect(:put => "/order_addresses/1").to route_to("order_addresses#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/order_addresses/1").to route_to("order_addresses#destroy", :id => "1")
    end

  end
end
