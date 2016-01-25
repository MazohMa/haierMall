require 'rails_helper'

RSpec.describe ProductController, :type => :controller do

  describe "GET self" do
    it "returns http success" do
      get :self
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET all" do
    it "returns http success" do
      get :all
      expect(response).to have_http_status(:success)
    end
  end

  describe "#new" do
    it "create a new product" do

    end
  end

end
